//
//  SqliteInter.h
//  SQLitePro
//
//  Created by zp on 15/12/26.
//  Copyright © 2015年 ZP. All rights reserved.
//

//@brief: SQLite通用接口封装
//@attention: 1.本身并不提供线程安全，用户可以通过Serial Dispatch Queue的方式，保证安全可靠访问
//            2.只是对通用的使用方式进行了封装，很多细节或者特殊的使用方式并未覆盖


#import <Foundation/Foundation.h>
#import <sqlite3.h>

//Sqlite支持的5种数据类型
typedef NS_ENUM(NSInteger, DataType)
{
    DTNULL = 0,     //NULL
    DTINT,          //整数
    DTREAL,         //浮点数
    DTTEXT,         //文本数据
    DTBLOB          //二进制数据
};

@interface SqliteInter : NSObject

//错误码
@property (assign, nonatomic) NSInteger lastErrCode;

//@brief:打开数据库文件
//@param:dbFile 数据库文件路径
//@return: 0 成功 其它 失败的错误码
- (NSInteger)openDB:(NSString *)dbFile;

//@brief:关闭数据库连接
//@return: YES 成功 NO 失败
- (NSInteger)closeDB;

//@breif: sql命令，返回执行状态
//@return: 0 成功
//         其它 错误码
//@attention: 主要执行查询，状态获取等
- (NSInteger)execSql:(NSString *)sql;

//@brief: 执行sql查询语句
//@param: dataType 指定查询返回的数据类型（注意需为DataType的枚举值）
//@return: 返回为双重数组，第一层为一行数据封装，第二层为列数据封装
//@attention: 内部会将所有的数据转化成NSString，用户需自己进行转化
- (NSArray<NSArray *> *)sqlQuery:(NSString *)sql
                                    dataType:(NSArray<NSNumber *> *)dataType;

//@brief: 数据插入
//@param: sql 插入的sql语句
//        data 绑定的值，而为数组形式，先封装一行数据，然后再封装
//        datatype 每一列数据的值
//@return:  >=0 影响的行数
//          -1  失败
//@attention: 内部不检测值和类型是否匹配，需用户自己校验
- (NSInteger)sqlInsert:(NSString*)sql data:(NSArray<NSArray *> *)data datatype:(NSArray *)datatype;

//@brief: 根据错误码，返回错误描述信息
- (NSString *)lastError:(NSInteger)errcode;

@end
