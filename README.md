# GNetworking
网络请求现在开源的那么多，还是没有觉得那一款合适自己，鞋子还是要适合自己的才舒服。
GNetworking是一个高度自定义，高效网络请求引擎。使用简单方便，请求链路再打印台清晰可见。请求结果返回状态判断清晰。

#使用

1.请求基础配置信息在GApiConfig配置类。

2.继承GApiBaseManager基础类, 实现协议<GAPIManager, GAPIManagerDataSource>; 使用协议防止子类越级。如果不是实现该协议就crash。

3.再请求之前可以使用<GAPIManagerValiator>进行验证判断，免去发起不必要的请求。

4.请求回调协议<GAPIBaseManagerRequestCallBackDelegate>，实现该协议进行数据层&UI层之间的处理。

5.数据处理协议<GApiBaseManagerCallBackDataTransformer>，现在不是很流行MVVC模型嘛。这个协议很方便，而且很快捷的去处理数据转换获取需要的数据模式，然后给出去。它充当了其中的V的桥梁。

EX：

#import "GApiBaseManager.h"

@interface GetUserInfoApi : GApiBaseManager<GAPIManager, GAPIManagerDataSource>

@end

#import "GetUserInfoApi.h"

@implementation GetUserInfoApi

- (id)init {
    if (self = [super init]) {
        self.dataSource = self;
    }
    return self;
}

- (NSString *)requestUrl {
    return @"requestRUL";
}

- (NSDictionary *)paramsForApi {
    return YouRequestParams;
}

@end


其他的重载方法请看父类。更多详情使用请查看DEMO。

