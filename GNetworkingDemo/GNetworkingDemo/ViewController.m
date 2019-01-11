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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UINavigationBar *Bar = self.navigationController.navigationBar;
    CGRect frame = Bar.frame;
    frame.size.height = 200;
    [Bar setFrame:frame];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"nimabi";
    self.navigationItem.prompt = @"test";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    for (UIView *vola in self.navigationController.navigationBar.subviews) {
        NSLog(@"%@", NSStringFromClass([vola class]));
        if ([NSStringFromClass([vola class]) isEqualToString:@"_UIBarBackground"]) {
//            UILabel *prompt = vola.subviews.firstObject;
//            prompt.textColor = [UIColor redColor];
//            prompt.font = [UIFont boldSystemFontOfSize:20];
//            prompt.textColor = [UIColor clearColor];
            [vola setFrame:CGRectMake(0, 0, vola.frame.size.width, 100)];
            vola.backgroundColor = [UIColor redColor];
        }
    }
    //发起请求
    self.chartApi = [[KLineListManager alloc] init];
    self.chartApi.delegate = self;
    self.chartApi.dateType = @"d";
    self.chartApi.kLineID = @"601888.SS";
    [self.chartApi startRequest];
    
    _lineListTransformer = [KLineListTransformer new];
}

#pragma mark - GAPIBaseManagerRequestCallBackDelegate

- (void)manager:(__kindof GApiBaseManager *)manager didApiCallBackSuccessData:(id)data {
    NSDictionary *lineData = (NSDictionary *)data;
    NSLog(@"result: %@", lineData);
}

- (void)managerApiCallBackDidFailed:(__kindof GApiBaseManager *)manager {
    
}

@end
