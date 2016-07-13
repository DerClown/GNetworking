
//
//  MatchAPIManager.m
//  GeitNetwoking
//
//  Created by liuxd on 16/7/11.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import "MatchAPIManager.h"
#import "NSString+md5.h"

@interface MatchAPIManager ()

@end

@implementation MatchAPIManager

-(id)init {
    if (self = [super init]) {
        self.dataSource = self;
    }
    return self;
}

- (NSString *)requestUrl {
    return nil;
}

- (NSDictionary *)paramsForApi {
    return nil;
}

- (BOOL)shouldCache {
    return YES;
}

@end
