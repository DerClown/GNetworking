//
//  ViewController.m
//  GNetworkingDemo
//
//  Created by xdliu on 16/8/21.
//  Copyright © 2016年 xdliu. All rights reserved.
//

#import "ViewController.h"
#import "KLineListManager.h"
#import "KLineListTransformer.h"


@interface ViewController ()<GAPIBaseManagerRequestCallBackDelegate>

@property (nonatomic, strong) KLineListManager *chartApi;
@property (nonatomic, strong) KLineListTransformer *lineListTransformer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //发起请求
    self.chartApi = [[KLineListManager alloc] init];
    self.chartApi.delegate = self;
    self.chartApi.dateType = @"d";
    self.chartApi.kLineID = @"601888.SS";
    [self.chartApi startRequest];
    
    _lineListTransformer = [KLineListTransformer new];
}

#pragma mark - GAPIBaseManagerRequestCallBackDelegate

- (void)managerApiCallBackDidSuccess:(__kindof GApiBaseManager *)manager {
    NSDictionary *lineData = [self.chartApi fetchDataWithTransformer:self.lineListTransformer];
    NSLog(@"result: %@", lineData);
}

- (void)managerApiCallBackDidFailed:(__kindof GApiBaseManager *)manager {
    
}

@end
