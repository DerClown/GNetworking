//
//  UserInfoApi.h
//  GNetworkingDemo
//
//  Created by YoYo on 2019/1/11.
//  Copyright © 2019 xdliu. All rights reserved.
//

#import "GApiBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserInfoApi : GApiBaseManager<GAPIManager, GAPIManagerDataSource, GAPIBaseManagerCallBackDataTransformerToTargetModel>

@end

NS_ASSUME_NONNULL_END
