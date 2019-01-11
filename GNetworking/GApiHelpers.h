//
//  GApiHelpers.h
//  GNetworkingDemo
//
//  Created by YoYo on 2019/1/11.
//  Copyright © 2019 xdliu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GApiHelpers : NSObject

+ (id)rawData:(id)rowData transformerToTargetModel:(Class)targetModel;

@end

NS_ASSUME_NONNULL_END
