//
//  UserInfoApi.m
//  GNetworkingDemo
//
//  Created by YoYo on 2019/1/11.
//  Copyright © 2019 xdliu. All rights reserved.
//

#import "UserInfoApi.h"
#import "UserInfoModel.h"

@implementation UserInfoApi
- (id)init {
    if (self = [super init]) {
        self.dataSource = self;
        self.transformerToTargetModel = self;
    }
    return self;
}

- (NSString *)requestUrl {
    return @"http://xxxxxxxxxxxxxx";
}

- (NSDictionary *)paramsForApi {
    return nil;
}

// 实现了该协议，外部拿到的数据，就是一个UserInfoModel对象
- (Class)rawDataTransformerToTargetModel {
    return UserInfoModel.class;
}

@end
