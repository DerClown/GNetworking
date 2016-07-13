//
//  ViewController.m
//  GeitNetwoking
//
//  Created by liuxd on 16/6/1.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import "ViewController.h"
#import "MatchAPIManager.h"
#import "DataTransformer.h"
#import "GApiCache.h"

@interface ViewController ()<GAPIBaseManagerRequestCallBackDelegate>

@property (nonatomic, strong) UIView *ew;

@property (nonatomic, strong) MatchAPIManager *matchApi;

@property (nonatomic, strong) id<GApiBaseManagerCallBackDataTransformer>eTransformer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _eTransformer = [[DataTransformer alloc] init];
    _matchApi = [[MatchAPIManager alloc] init];
    _matchApi.delegate = self;
    _matchApi.isDataFromCacheFirst = YES;
    [_matchApi startRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)managerApiCallBackDidSuccess:(__kindof GApiBaseManager *)manager {
    [manager fetchDataWithTransformer:_eTransformer];
}

- (void)managerApiCallBackDidFailed:(__kindof GApiBaseManager *)manager {
    
}

@end
