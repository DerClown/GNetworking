//
//  KLineListTransformer.h
//  ChartDemo
//
//  Created by xdliu on 16/8/12.
//  Copyright © 2016年 taiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GApiBaseManager.h"

extern NSString *const kKLineListKeyContext;
extern NSString *const kKLineListKeyDate;
extern NSString *const kKLineListKeyMaxHigh;
extern NSString *const kKLineListKeyMinLow;
extern NSString *const kKLineListKeyMaxVol;
extern NSString *const kKLineListKeyMinVol;
/**
 *  extern key 可修改为Entity
 */
@interface KLineListTransformer : NSObject<GAPIBaseManagerCallBackDataUseCustomTransformer>

@end
