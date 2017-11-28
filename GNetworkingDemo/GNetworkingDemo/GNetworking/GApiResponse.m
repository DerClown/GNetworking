//
//  GURLResponse.m
//  GeitNetwoking
//
//  Created by liuxd on 16/7/8.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import "GApiResponse.h"

@interface GApiResponse ()

@property (nonatomic, assign, readwrite) GApiResponseStatus status;

@property (nonatomic, copy, readwrite) id rawData;
@property (nonatomic, copy, readwrite) NSString *reponseString;
@property (nonatomic, copy, readwrite) NSData *responseData;
@property (nonatomic, copy, readwrite) NSDictionary *requestParams;

@property (nonatomic, assign, readwrite) NSInteger requestId;
@property (nonatomic, assign, readwrite) BOOL isCache;

@property (nonatomic, copy, readwrite) NSString *errorMessage;

@end

@implementation GApiResponse

- (instancetype)initWithRequestId:(NSNumber *)requestId requestParams:(NSDictionary *)requestParams responseObject:(NSData *)responseObject error:(NSError *)error {
    self = [super init];
    if (self) {
        self.status = [self responseStatusWithError:error];
        self.responseData = responseObject;
        self.rawData = responseObject ? [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil] : nil;
        self.reponseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        self.requestParams = requestParams;
        self.requestId = [requestId integerValue];
        self.isCache = NO;
        
        self.errorMessage = [self errorMessageWithError:error];
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        self.status = [self responseStatusWithError:nil];
        self.responseData = data;
        self.reponseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        self.requestId = 0;
        self.isCache = YES;
    }
    return self;
}

#pragma mark - private methods

- (GApiResponseStatus)responseStatusWithError:(NSError *)error {
    if (error) {
        GApiResponseStatus result = GApiResponseStatusFailed;
        
        // 除了超时以外，所有错误都当成是无网络
        if (error.code == NSURLErrorTimedOut) {
            result = GApiResponseStatusErrorTimeout;
        }
        return result;
    } else {
        return GApiResponseStatusSuccess;
    }
}

- (NSString *)errorMessageWithError:(NSError *)error {
    if (error.code == NSURLErrorTimedOut) {
        return @"网络不给力哦";
    }
    
    return nil;
}

@end
