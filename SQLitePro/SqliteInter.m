//
//  SqliteInter.m
//  SQLitePro
//
//  Created by zp on 15/12/26.
//  Copyright © 2015年 ZP. All rights reserved.
//

/**@brief:SQLite数据接口封装，方便复用
 *
 *
 */

#import "SqliteInter.h"

@interface SqliteInter ()

//注意：sqlite3 为struct类型，不能用strong属性
@property (assign, nonatomic) sqlite3 *database;

@property (assign, nonatomic) sqlite3_stmt *stmt;

@end


@implementation SqliteInter

- (NSInteger)openDB:(NSString *)dbFile
{
    
    //如果数据库已经打开，则先关闭
    if (_database)
    {
        _lastErrCode = [self closeDB];
        if (_lastErrCode != SQLITE_OK)
        {
            _lastErrCode = 0;
            return 0;
        }
    }
    
    _lastErrCode = sqlite3_open([dbFile UTF8String], &_database);
    return _lastErrCode;
}

- (NSInteger)closeDB
{
    if (_database)
    {
        NSInteger num = 0;
        //会关闭2次，2次失败，则失败
        while (num < 2)
        {
            _lastErrCode = sqlite3_close(_database);
            //关闭成功
            if (SQLITE_OK == _lastErrCode)
            {
                _database = nil;
                break;
            }
            sqlite3_finalize(_stmt);
            num++;
        }
    }
    return _lastErrCode;
}

- (NSInteger)execSql:(NSString *)sql
{
    //这个地方并不校验 _database == nil, errorcode 会有描述
    
    _lastErrCode = sqlite3_exec(_database, [sql UTF8String], NULL, NULL, NULL);
    //返回错误码
    return _lastErrCode;
}

- (NSArray<NSArray *> *)sqlQuery:(NSString *)sql
                                    dataType:(NSArray<NSNumber *> *)dataType
{
    NSMutableArray *dataSet = [[NSMutableArray alloc] init];
    NSInteger preRes = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &_stmt, nil);
    if (preRes == SQLITE_OK)
    {
        while (sqlite3_step(_stmt) == SQLITE_ROW)
        {
            NSMutableArray *dataArr = [[NSMutableArray alloc] init];
            int colNum = sqlite3_data_count(_stmt);
            //获取列的数量
            for (int i=0; i<colNum; i++)
            {
                [dataArr addObject:[self get_col_data:dataType[i].intValue statement:_stmt col:i]];
            }
            [dataSet addObject:dataArr];
        }
    }
    sqlite3_finalize(_stmt);
    return dataSet;
}

- (id) get_col_data:(DataType)dbtype statement:(sqlite3_stmt *)stmt col:(NSInteger)col
{
    switch (dbtype) {
        case DTNULL:
            return [NSNull null];
            break;
        case DTINT:{
            //(int)col 强制转化，避免警告
            NSNumber *number = [NSNumber numberWithInt:sqlite3_column_int(stmt, (int)col)];
            return number;
            break;
            }
        case DTREAL:{
            NSNumber *number = [NSNumber numberWithFloat:sqlite3_column_double(stmt, (int)col)];
            return number;
            }
        case DTTEXT:{
            NSString *cellData;
            char* str = (char*)(char*)sqlite3_column_text(stmt, (int)col);
            if (str != NULL)
            {
                cellData = [NSString stringWithFormat:@"%s", str];
            }
            else
            {
                //当为空的时候，为一个空对象
                cellData = @"";
            }
            return cellData;
        }
        //二进制的处理
        case DTBLOB:{
            NSInteger len = sqlite3_column_bytes(stmt, (int)col);
            NSData *cellData = [[NSData alloc] initWithBytes:sqlite3_column_blob(stmt, (int)col) length:len];
            return cellData;
        }
        default:
            break;
    }
    return  [NSNull null];
}

- (NSInteger)sqlInsert:(NSString*)sql data:(NSArray<NSArray *> *)data datatype:(NSArray *)datatype
{
    NSInteger effectNum = 0;
    int preStatus = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &_stmt, NULL);
    if (preStatus == SQLITE_OK)
    {
        for (int i=0; i<data.count; i++)
        {
            NSArray *rowData = data[i];
            for (int col=0; col<rowData.count; col++)
            {
                NSNumber *type = datatype[col];
                switch (type.intValue) {
                    case DTNULL:
                        sqlite3_bind_null(_stmt, col+1);
                        break;
                    case DTINT:{
                        NSNumber *number = rowData[col];
                        sqlite3_bind_int(_stmt, col+1, number.intValue);
                        break;
                    }
                    case DTREAL:{
                        NSNumber *real = rowData[col];
                        sqlite3_bind_double(_stmt, col+1, real.floatValue);
                        break;
                    }
                    case DTTEXT:{
                        NSString *str;
                        if (rowData[col] == [NSNull null])
                        {
                            str = @"";
                        }
                        else
                        {
                            str = rowData[col];
                        }
                        sqlite3_bind_text(_stmt, col+1, [str UTF8String], -1, NULL);
                        break;
                    }
                    case DTBLOB:{
                        NSData *msg;
                        if (rowData[col] == [NSNull null])
                        {
                            msg = [[NSData alloc] initWithBytes:@"" length:1];
                        }
                        else
                        {
                            msg = rowData[col];
                        }
                        sqlite3_bind_blob(_stmt, col+1, [msg bytes], (int)[msg length], NULL);
                        break;
                    }
                    default:
                        break;
                } /*switch */
            } //for
            if (sqlite3_step(_stmt) == SQLITE_DONE)
            {
                effectNum++;
            }
            //需要重置statement
            sqlite3_reset(_stmt);
        } /*for*/
    } /*if*/
    
    sqlite3_finalize(_stmt);
    return effectNum;
    //这种用法不对
    //return sqlite3_changes(_database);
}

- (NSString *)lastError:(NSInteger)errcode
{
    return [NSString stringWithUTF8String:sqlite3_errstr((int)errcode)];
}



















@end