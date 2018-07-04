//
//  GApiAgent.m
//  GeitNetwoking
//
//  Created by liuxd on 16/6/2.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import "GApiAgent.h"
#import "GApiConfig.h"
#import "NSDictionary+NetWorkingMehods.h"
#import "GApiLogger.h"

@interface GApiAgent ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSMutableDictionary *taskTables;
@property (nonatomic, strong) NSNumber *recordedRequestId;

@property (nonatomic, strong) GApiConfig *config;

@end

@implementation GApiAgent

+ (instancetype)sharedInstance
{
    static GApiAgent* instance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [GApiAgent new];
    });

    return instance;
}

- (id)init {
    if (self = [super init]) {
        _taskTables = [NSMutableDictionary new];
        _config = [GApiConfig sharedInstance];
        
        _manager = [AFHTTPSessionManager manager];
        _manager.operationQueue.maxConcurrentOperationCount = 3;
        _manager.securityPolicy = _config.securityPolicy;
    }
    return self;
}

- (void)configRequestManagerSerializer {
    AFHTTPRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    _manager.requestSerializer = requestSerializer;
    
    // 用户名密码
    NSArray *authorizationHeaderFieldArray = [_config requestAuthorizationHeaderFieldArray];
    if (authorizationHeaderFieldArray != nil) {
        [_manager.requestSerializer setAuthorizationHeaderFieldWithUsername:(NSString *)authorizationHeaderFieldArray.firstObject
                                                                   password:(NSString *)authorizationHeaderFieldArray.lastObject];
    }
    
    // HTTP报头
    NSDictionary *headerFieldValueDictionary = [_config requestHeaderFieldValueDictionary];
    if (headerFieldValueDictionary != nil) {
        for (id httpHeaderField in headerFieldValueDictionary.allKeys) {
            id value = headerFieldValueDictionary[httpHeaderField];
            if ([httpHeaderField isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
                [_manager.requestSerializer setValue:(NSString *)value forHTTPHeaderField:(NSString *)httpHeaderField];
            } else {
                NSLog(@"Error, class of key/value in headerFieldValueDictionary should be NSString.");
            }
        }
    }
    
    AFHTTPResponseSerializer *responsSerializer = [AFJSONResponseSerializer serializer];
    _manager.responseSerializer = responsSerializer;
    if (_config.acceptableContentTypes) {
        _manager.responseSerializer.acceptableContentTypes = _config.acceptableContentTypes;
    }
}

- (NSInteger)sendRequestApi:(__kindof GApiBaseManager *)api
                    success:(GAPICallBack)success
                    failure:(GAPICallBack)failure {
    NSAssert(api.child.requestUrl.length != 0, @"作为GApiBaseManager的孩子，必须实现【GAPIManager】的requestUrl协议，同时requestUrl不能为空。");
    
    NSString *url = [self api:api buildRequestUrl:api.child.requestUrl];
    
    NSDictionary *params = [api.dataSource paramsForApi];
    
    NSMutableDictionary *requestParams = params.mutableCopy;
    // 合并全局参数
    [requestParams addEntriesFromDictionary:_config.filterApiParams];
    
    GAPIManagerRequestType requestType = api.child.requestType;
    
    [self configRequestManagerSerializer];
    
    if (api.child.requestTimeoutInterval > 0) {
        _manager.requestSerializer.timeoutInterval = api.child.requestTimeoutInterval;
    } else {
        _manager.requestSerializer.timeoutInterval = _config.requestTimeoutInterval;
    }
    
    // 之所以不用getter，是因为如果放到getter里面的话，每次调用self.recordedRequestId的时候值就都变了，违背了getter的初衷
    __block NSNumber *taskId = [self generateRequestId];
    
    NSURLSessionTask *dataTask = nil;
    
    __weak __typeof(self) weakSelf = self;
    if (requestType == GAPIManagerRequestTypeGet) {
        if (api.child.resumableDownloadPath) {
            NSString *downloadUrl = [self urlStringWithOriginUrlString:url appendParameters:params];
            
            NSData *resumeData = [NSData dataWithContentsOfFile:api.child.resumableDownloadPath];
            if (resumeData) {
                dataTask = [_manager downloadTaskWithResumeData:resumeData progress:api.child.downloadProgressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                    return [NSURL URLWithString:api.child.resumableDownloadPath];
                } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (!error) {
                        [strongSelf apiCallBackSuccessWithTaskId:taskId requestParamers:requestParams reponseObject:nil success:success];
                    } else {
                        [strongSelf apiCallBackFailedWithTaskId:taskId requestParamers:requestParams error:error failure:failure];
                    }
                }];
            } else {
                NSURLRequest *downReq = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadUrl]];
                dataTask = [_manager downloadTaskWithRequest:downReq progress:api.child.downloadProgressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                    return [NSURL URLWithString:api.child.resumableDownloadPath];
                } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (!error) {
                        [strongSelf apiCallBackSuccessWithTaskId:taskId requestParamers:requestParams reponseObject:nil success:success];
                    } else {
                        [strongSelf apiCallBackFailedWithTaskId:taskId requestParamers:requestParams error:error failure:failure];
                    }
                }];
            }
        } else {
            dataTask = [_manager GET:url parameters:requestParams progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf apiCallBackSuccessWithTaskId:taskId requestParamers:requestParams reponseObject:responseObject success:success];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf apiCallBackFailedWithTaskId:taskId requestParamers:requestParams error:error failure:failure];
            }];
        }
    } else if (api.child.requestType == GAPIManagerRequestTypePost) {
        if (api.child.constructingBodyBlock) {
            dataTask = [_manager POST:url parameters:requestParams constructingBodyWithBlock:api.child.constructingBodyBlock progress:api.child.uploadProgressBlock success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf apiCallBackSuccessWithTaskId:taskId requestParamers:requestParams reponseObject:responseObject success:success];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf apiCallBackFailedWithTaskId:taskId requestParamers:requestParams error:error failure:failure];
            }];
        } else {
            dataTask = [_manager POST:url parameters:requestParams progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf apiCallBackSuccessWithTaskId:taskId requestParamers:requestParams reponseObject:responseObject success:success];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf apiCallBackFailedWithTaskId:taskId requestParamers:requestParams error:error failure:failure];
            }];
        }
    } else if (api.child.requestType == GAPIManagerRequestTypeHead) {
        dataTask = [_manager HEAD:url parameters:requestParams success:^(NSURLSessionDataTask * _Nonnull task) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf apiCallBackSuccessWithTaskId:taskId requestParamers:requestParams reponseObject:nil success:success];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf apiCallBackFailedWithTaskId:taskId requestParamers:requestParams error:error failure:failure];
        }];
    } else if (api.child.requestType == GAPIManagerRequestTypePut) {
        dataTask = [_manager PUT:url parameters:requestParams success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf apiCallBackSuccessWithTaskId:taskId requestParamers:requestParams reponseObject:responseObject success:success];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf apiCallBackFailedWithTaskId:taskId requestParamers:requestParams error:error failure:failure];
        }];
    } else if (api.child.requestType == GAPIManagerRequestTypePatch) {
        dataTask = [_manager PATCH:url parameters:requestParams success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf apiCallBackSuccessWithTaskId:taskId requestParamers:requestParams reponseObject:responseObject success:success];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf apiCallBackFailedWithTaskId:taskId requestParamers:requestParams error:error failure:failure];
        }];
    } else {
        dataTask = [_manager DELETE:url parameters:requestParams success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            __strong typeof(weakSelf)  strongSelf = self;
            [strongSelf apiCallBackSuccessWithTaskId:taskId requestParamers:requestParams reponseObject:responseObject success:success];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            __strong typeof(weakSelf)  strongSelf = self;
            [strongSelf apiCallBackFailedWithTaskId:taskId requestParamers:requestParams error:error failure:failure];
        }];
    }
    
    // 优先级设置
    switch (api.child.requestPriority) {
        case GAPIManagerRequestPriorityHigh:
            dataTask.priority = NSURLSessionTaskPriorityHigh;
            break;
        case GAPIManagerRequestPriorityLow:
            dataTask.priority = NSURLSessionTaskPriorityLow;
            break;
        case GAPIManagerRequestPriorityDefault:
        default:
            dataTask.priority = NSURLSessionTaskPriorityDefault;
            break;
    }
    
    [GApiLogger logDebugInfoWithRequest:dataTask.currentRequest reqeustParams:params reqeustMethod:(api.child.requestType == GAPIManagerRequestTypeGet ? @"GET" : @"POST")];
    
    if (dataTask) {
        @synchronized(self) {
            _taskTables[taskId] = dataTask;
        }
    }
    
    // 发起请求
    [dataTask resume];
    
    return taskId.integerValue;
}

- (void)apiCallBackSuccessWithTaskId:(NSNumber *)taskId requestParamers:(NSDictionary *)paramers reponseObject:(id)responseObject success:(GAPICallBack)success {
    [GApiLogger logDebugInfoWithOperation:self.taskTables[taskId] reponseObject:responseObject error:nil];
    [self cancelRequestApiWithReqeustId:taskId];
    NSData *responseData = responseObject;
    GApiResponse *response = [[GApiResponse alloc] initWithRequestId:taskId requestParams:paramers responseObject:responseData error:nil];
    success ? success(response) : nil;
}

- (void)apiCallBackFailedWithTaskId:(NSNumber *)taskId requestParamers:(NSDictionary *)paramers error:(NSError *)error failure:(GAPICallBack)failure {
    [GApiLogger logDebugInfoWithOperation:self.taskTables[taskId] reponseObject:nil error:error];
    [self cancelRequestApiWithReqeustId:taskId];
    GApiResponse *response = [[GApiResponse alloc] initWithRequestId:taskId requestParams:paramers responseObject:nil error:error];
    failure ? failure(response) : nil;
}

- (void)cancelRequestApiWithReqeustId:(NSNumber *)requestId {
    @synchronized (self) {
        NSURLSessionTask *task = _taskTables[requestId];
        [task cancel];
        [_taskTables removeObjectForKey:requestId];
    }
}

- (void)cancelRequestApiWithRequestIdList:(NSArray *)requestIdList {
    for (NSNumber *requestId in requestIdList) {
        [self cancelRequestApiWithReqeustId:requestId];
    }
}

#pragma mark - private methods

- (NSString *)api:(__kindof GApiBaseManager *)api buildRequestUrl:(NSString *)requestUrl {
    NSString *applyUrl = requestUrl;
    if ([applyUrl hasPrefix:@"http"]) {
        return applyUrl;
    }
    
    if (![applyUrl hasPrefix:@"/"]) {
        applyUrl = [@"/" stringByAppendingString:applyUrl];
    }
    
    if ([api.child respondsToSelector:@selector(service)]) {
        return [NSString stringWithFormat:@"%@%@", api.child.service, applyUrl];
    }
    
    NSAssert(_config.baseUrl.length != 0, @"_baseUrl不能为空。");
    
    return [NSString stringWithFormat:@"%@%@", _config.baseUrl, applyUrl];
}

- (NSString *)urlStringWithOriginUrlString:(NSString *)originUrlString appendParameters:(NSDictionary *)parameters {
    NSString *filteredUrl = originUrlString;
    NSString *paraUrlString = [parameters urlParamsString];
    if (paraUrlString && paraUrlString.length > 0) {
        if ([originUrlString rangeOfString:@"?"].location != NSNotFound) {
            filteredUrl = [filteredUrl stringByAppendingString:paraUrlString];
        } else {
            filteredUrl = [filteredUrl stringByAppendingFormat:@"?%@", paraUrlString];
        }
        return filteredUrl;
    } else {
        return originUrlString;
    }
}

#pragma mark - getters

- (NSNumber *)generateRequestId {
    if (_recordedRequestId == nil) {
        _recordedRequestId = @(1);
    } else {
        if ([_recordedRequestId integerValue] == NSIntegerMax) {
            _recordedRequestId = @(1);
        } else {
            _recordedRequestId = @([_recordedRequestId integerValue] + 1);
        }
    }
    return _recordedRequestId;
}

@end
