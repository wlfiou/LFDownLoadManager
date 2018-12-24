//
//  ViewController.m
//  LFDownloadDemo
//
//  Created by 王鹭飞 on 2018/12/11.
//  Copyright © 2018 王鹭飞. All rights reserved.
//
#import "ViewController.h"
#import "LFUtil.h"
#import "LFDownloadListCell.h"
#import "LFDownLoadManager/LFDownLoadModel.h"
#import "LFDownLoadManager/LFDownLoadDatabaseManager.h"
#import "category/UIColor+LF.h"
#import "LFPlayVC.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *table;
@property(nonatomic,strong)NSMutableArray <LFDownLoadModel *>*dataArray;
@property(nonatomic,strong)RLMNotificationToken *DBToken;

@end

@implementation ViewController
-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = NSMutableArray.array;
    }
    return _dataArray;
}

-(UITableView *)table
{
    if (!_table) {
        _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
        _table.delegate = self;
        _table.dataSource = self;
        _table.separatorStyle = NO;
        _table.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        [_table registerClass:[LFDownloadListCell class] forCellReuseIdentifier:@"LFDownloadListCell"];
        _table.rowHeight = 70;
    }
     return _table;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.table];
    [self loadData];
    [self addNotify];
    
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)addNotify{
    // 进度通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downLoadProgress:) name:LFDownloadProgressNotification object:nil];
    // 状态改变通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downLoadStateChange:) name:LFDownloadStateChangeNotification object:nil];
}
-(void)downLoadProgress:(NSNotification *)notify{
    [self.dataArray enumerateObjectsUsingBlock:^(LFDownLoadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LFDownLoadModel *model = notify.object;
        if ([obj.url isEqualToString:model.url]) {
            obj = model;
            LFDownloadListCell *cell = [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
            [cell setModel:obj];
            
        }
    }];
}
-(void)downLoadStateChange:(NSNotification *)notify{
    [self.dataArray enumerateObjectsUsingBlock:^(LFDownLoadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LFDownLoadModel *model = notify.object;
        if ([obj.url isEqualToString:model.url]) {
            obj = model;
            LFDownloadListCell *cell = [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
            [cell setModel:obj];
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    /*
    __weak __typeof(self) weakself = self;
    _DBToken = [[LFDownLoadModel allObjectsInRealm:[LFDataBase db]] addNotificationBlock:^(RLMResults * _Nullable results, RLMCollectionChange * _Nullable change, NSError * _Nullable error) {
        __strong __typeof(self) self = weakself ;
        if(!change ||error) {
            return ;
        }
        //这里如果是新增数据直接处理就好，demo要不断改变不定个数状态，所以自己写了通知
    }];
     */
}

-(void)loadData{
    NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"testData" ofType:@"plist"]];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LFDownLoadModel *model = [[LFDownLoadModel alloc]initVid:obj[@"vid"] fileName:obj[@"fileName"] url:obj[@"url"]];
        [self.dataArray addObject:model];
    }];
    [self.table reloadData];
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LFDownLoadModel *model = self.dataArray[indexPath.row];
    LFDownLoadModel *downModel = [[LFDownLoadDatabaseManager shareManager] getModelWithUrl:model.url];
    if (downModel.state == LFDownloadStateFinish) {
        LFPlayVC *vc = [[LFPlayVC alloc] init];
        vc.model = downModel;
        [self presentViewController:vc animated:NO completion:nil ];
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LFDownloadListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LFDownloadListCell" forIndexPath:indexPath];
    LFDownLoadModel *localMode = [[LFDownLoadDatabaseManager shareManager] getModelWithUrl:self.dataArray[indexPath.row].url];
    if (localMode) {
        cell.model = localMode;
    }else{
        cell.model = self.dataArray[indexPath.row];
    }
    cell.selectionStyle = NO;
    return cell;
}
-(void)dealloc{
    [_DBToken stop];
    _DBToken = nil;
}
@end
