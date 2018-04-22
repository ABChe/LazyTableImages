//
//  RunLoopViewController.m
//  LazyTableImages
//
//  Created by 车 on 2018/4/11.
//  Copyright © 2018年 车. All rights reserved.
//

#import "RunLoopViewController.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"
#import "JSONModel.h"
#import "AppRecord.h"
#import "RunLoopTableViewCell.h"

@interface RunLoopViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation RunLoopViewController


#pragma mark - Lifecycle

- (instancetype)init {
    if (self = [super init]) {
        self.dataArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [[SDWebImageDownloader sharedDownloader] cancelAllDownloads];
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RunLoopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[RunLoopTableViewCell description] forIndexPath:indexPath];
    AppRecord *model = self.dataArray[indexPath.row];
    [cell setModel:model indexPath:indexPath];
    return cell;
}


#pragma mark - Method

- (void)loadData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"appList" ofType:@"plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    self.dataArray = [AppRecord arrayOfModelsFromDictionaries:[dic valueForKey:@"data"]
                                                        error:nil];
    [self.tableView reloadData];
}


#pragma mark - Lazyloading

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        _tableView.estimatedRowHeight = 44.f;
        _tableView.estimatedSectionHeaderHeight = 0.f;
        _tableView.estimatedSectionFooterHeight = 0.f;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.allowsSelection = NO;
        [_tableView registerClass:[RunLoopTableViewCell class]forCellReuseIdentifier:[RunLoopTableViewCell description]];
    }
    return _tableView;
}

@end
