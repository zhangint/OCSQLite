//
//  ViewController.m
//  SQLitePro
//
//  Created by zp on 15/12/26.
//  Copyright © 2015年 ZP. All rights reserved.
//

#import "ViewController.h"

#define SWIDTH      [UIScreen mainScreen].bounds.size.width
#define SHEIGHT     [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) UITableView * tableView;
@property (strong, nonatomic) NSArray<NSArray *> *searchRes;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //连接数据库 测试按钮
    UIButton *clickBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 50)];
    [clickBtn setTitle:@"连接数据库" forState:UIControlStateNormal];
    [clickBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [clickBtn addTarget:self action:@selector(conClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clickBtn];
    
    //插入数据 测试按钮
    UIButton *insertBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 150, 100, 50)];
    [insertBtn setTitle:@"插入数据" forState:UIControlStateNormal];
    [insertBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [insertBtn addTarget:self action:@selector(insertClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:insertBtn];
    
    //查询数据 测试按钮
    UIButton *searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 100, 50)];
    [searchBtn setTitle:@"查询数据" forState:UIControlStateNormal];
    [searchBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchBtn];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 280, SWIDTH, SHEIGHT-280)];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    _tableView = tableView;
}

- (void)conClicked:(id)sender
{
    _dbcon = [[SqliteInter alloc] init];
    NSString *dbData = [NSString stringWithFormat:@"%@/%@", [self dbPath], @"test.db"];
    NSLog(@"db path:%@", [self dbPath]);
    NSInteger status = [_dbcon openDB:dbData];
    if (status != 0)
    {
        NSLog(@"open db error code:%ld.", status);
    }
    else
    {
        NSLog(@"link db success");
    }
}

- (void)insertClicked:(id)sender
{
    //在插入数据的时候，先创建表
    NSString *sql = @"create table if not exists test_table_1 \
        (id integer primary key autoincrement,\
        name,   \
        passwd, \
        address,\
        age,    \
        photo,  \
        rank)";
    
    NSLog(@"create table status:%ld", [_dbcon execSql:sql]);
    
    //构造一行的数据
    NSMutableArray *rowData_1 = [[NSMutableArray alloc] init];
    [rowData_1 addObject:@"zhangint"];
    [rowData_1 addObject:@"123456"];
    [rowData_1 addObject:@"chengdu"];
    [rowData_1 addObject:[NSNumber numberWithInt:25]];
    NSString *pic1 = [[NSBundle mainBundle] pathForResource:@"zhangint" ofType:nil];
    NSData *pic1_data = [NSData dataWithContentsOfFile:pic1];
    unsigned char* msg = (unsigned  char*)[pic1_data bytes];
    [rowData_1 addObject:pic1_data];  //二进制
    [rowData_1 addObject:[NSNumber numberWithFloat:2.3]];               //浮点数
    
    NSMutableArray *rowData_2 = [[NSMutableArray alloc] init];
    [rowData_2 addObject:@"love dog"];
    [rowData_2 addObject:@"56789"];
    [rowData_2 addObject:[NSNull null]];                                //string为空
    [rowData_2 addObject:[NSNumber numberWithInt:33]];
    NSString *pic2 = [[NSBundle mainBundle] pathForResource:@"xiaoyu" ofType:nil];
    NSData *pic2_data = [NSData dataWithContentsOfFile:pic2];
    [rowData_2 addObject:pic2_data];
    [rowData_2 addObject:[NSNumber numberWithFloat:3.3]];
    
    NSMutableArray *rowData_3 = [[NSMutableArray alloc] init];
    [rowData_3 addObject:@"xiaoxiaoxiao"];
    [rowData_3 addObject:@"9990"];
    [rowData_3 addObject:@"beijing"];
    [rowData_3 addObject:[NSNumber numberWithInt:32]];
    [rowData_3 addObject:[NSNull null]];                                //二进制位空
    [rowData_3 addObject:[NSNumber numberWithFloat:5.4]];
    
    //数据值的初始化
    NSArray *tableArr = [[NSArray alloc] initWithObjects:rowData_1, rowData_2, rowData_3, nil];
    //数据类型的初始化
    NSArray *dataType = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:DTTEXT],
        [NSNumber numberWithInt:DTTEXT],
        [NSNumber numberWithInt:DTTEXT],
        [NSNumber numberWithInt:DTINT],
        [NSNumber numberWithInt:DTBLOB],
        [NSNumber numberWithInt:DTREAL], nil];
    NSString *insertsql = @"insert into test_table_1 values(null, ?, ?, ?, ?, ?, ?)";
   
    NSLog(@"insert res:%ld", [_dbcon sqlInsert:insertsql data:tableArr datatype:dataType]);
}

- (void) searchClicked:(id)sender
{
    NSString *sql = @"select * from test_table_1";
    NSArray *dataType = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:DTINT],
                         [NSNumber numberWithInt:DTTEXT],
                         [NSNumber numberWithInt:DTTEXT],
                         [NSNumber numberWithInt:DTTEXT],
                         [NSNumber numberWithInt:DTINT],
                         [NSNumber numberWithInt:DTBLOB],
                         [NSNumber numberWithInt:DTREAL], nil];

    NSArray<NSArray *> *searchRes;
    searchRes = [_dbcon sqlQuery:sql dataType:dataType];
    NSInteger rows = [searchRes count];
    NSLog(@"search rows:%ld", rows);
    for (int i=0; i<rows; i++)
    {
        NSArray *rowData = searchRes[i];
        NSNumber *idnum = rowData[0];
        NSString *name = rowData[1];
        NSString *passed = rowData[2];
        NSString *address = rowData[3];
        NSNumber *age = rowData[4];
        //NSData *img = rowData[5];
        NSNumber *rank = rowData[6];
        NSLog(@"id:%d name:%@ passwd:%@ address:%@ age:%d photo not show rank:%.1f",idnum.intValue    , name, passed, address, age.intValue, rank.floatValue);
    }
    _searchRes = searchRes;
    //重新加载数据
    [self.tableView reloadData];
}

- (NSString *)dbPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

#pragma mask tableView的委托和数据处理，用于显示本例的查询数据

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"sqlcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    NSInteger row = indexPath.row;
    NSString *name = _searchRes[row][1];
    NSString *address = _searchRes[row][3];
    NSData *imgData = _searchRes[row][5];
    
    cell.textLabel.text = name;
    cell.detailTextLabel.text = address;
    cell.imageView.image = [UIImage imageWithData:imgData];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _searchRes.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
