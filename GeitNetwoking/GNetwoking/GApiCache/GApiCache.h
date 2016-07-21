//
//  NWCache.h
//  GeitNetwoking
//
//  Created by liuxd on 16/6/2.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GApiCache : NSObject

+ (instancetype)sharedInstance;

/**
 *  保存cache
 */
- (void)saveCacheWithData:(NSData *)cacheData requestURL:(NSString *)requestUrl requestParams:(NSDictionary *)params;

/**
 *  删除cache
 */
- (void)deleteCacheDataWithRequestURL:(NSString *)requestUrl requestParams:(NSDictionary *)params;

/**
 *  获取cache
 */
- (NSData *)fetchCacheDataWithRequestURL:(NSString *)requestUrl requestParams:(NSDictionary *)params;

- (long long)cacheVersion;

@end
