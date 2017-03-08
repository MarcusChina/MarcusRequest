//
//  MSDemoViewController.m
//  MarcusRequest
//
//  Created by marcus on 2016/11/24.
//  Copyright © 2016年 marcus. All rights reserved.
//

#import "MSDemoViewController.h"
#import "MSTaoBaoSearchManager.h"
#import "MSDuoMiManager.h"

@interface MSDemoViewController ()<MSAPIManagerApiCallBackDelegate,MSAPIManagerParamSourceDelegate>

@property (nonatomic, strong) NSArray *actorList;
@property (nonatomic, strong) MSTaoBaoSearchManager *taoBaoSearchManager;
@property (nonatomic, strong) NSMutableArray *duoMiArray;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MSDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    //此时是为了测试请求可以自动释放，放在此更容易出现效果，实际情况大多数发起请求应该放在viewDidLoad 或 viewWillAppear 中
    
    //请求淘宝所搜商品
    self.taoBaoSearchManager = [[MSTaoBaoSearchManager alloc]init];
    self.taoBaoSearchManager.delegate = self;
    self.taoBaoSearchManager.paramSource = self;
    [self.taoBaoSearchManager loadData];
    
    
    self.actorList = @[@"刘德华",@"张学友",@"王心凌",@"张杰",@"光良",@"陈奕迅",@"王力宏",@"汪峰",@"莫文蔚",@"王菲"];
    self.duoMiArray = [[NSMutableArray alloc]init];
    self.dataArray = [[NSMutableArray alloc]init];
    //请求列表中歌手的歌曲,循环请求,为了更好地演示网络请求自动取消的情况
    for (int i=0; i<6; i++) {
        for (NSString *actorName in self.actorList) {
            MSDuoMiManager *duoMiManager = [[MSDuoMiManager alloc]init];
            [self.duoMiArray addObject:duoMiManager];
            duoMiManager.delegate = self;
            duoMiManager.paramSource = self;
            duoMiManager.requestMark = actorName;
            [duoMiManager loadData];
        }
    }
}

#pragma mark -- MSAPIManagerParamSourceDelegate 
- (NSDictionary *)paramsForApi:(MSAPIBaseManager *)manager {
    NSMutableDictionary * params = [[NSMutableDictionary alloc]init];
    if ([manager isKindOfClass:[MSTaoBaoSearchManager class]]) {
        [params setObject:@"笔记本" forKey:@"q"];
        
    }else if ([manager isKindOfClass:[MSDuoMiManager class]]) {
        [params setObject:@"刘德华" forKey:@"kw"];
        [params setObject:@"0" forKey:@"pi"];
        [params setObject:@"1000" forKey:@"pz"];
    }
    return params;
}

#pragma mark -- MSAPIManagerApiCallBackDelegate
- (void)managerCallAPIDidSuccess:(MSAPIBaseManager *)manager {
    if ([manager isKindOfClass:[MSTaoBaoSearchManager class]]) {
        NSLog(@"搜索结果: %@",manager.responseObject);
    }else if ([manager isKindOfClass:[MSDuoMiManager class]]) {
        NSArray *tracks = [manager.responseObject objectForKey:@"tracks"];
        for (NSDictionary *tempDic in tracks) {
            NSLog(@"\n %@：%@",manager.requestMark,[tempDic objectForKey:@"title"]);
            [self.dataArray addObject:[tempDic objectForKey:@"title"]];
            [self.tableView reloadData];
        }
    }
}

- (void)managerCallAPIDidFailed:(MSAPIBaseManager *)manager {
    NSLog(@"失败原因：%@",manager.errorMessage);
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
    }
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

@end
