//
//  GApiHelpers.m
//  GNetworkingDemo
//
//  Created by YoYo on 2019/1/11.
//  Copyright © 2019 xdliu. All rights reserved.
//

#import "GApiHelpers.h"
#import "YYModel.h"

@implementation GApiHelpers

+ (id)rawData:(id)rowData transformerToTargetModel:(Class)targetModel {
    if (targetModel) {
        id targetObject;
        if ([rowData isKindOfClass:[NSArray class]]) {
            NSArray *lists = (NSArray *)rowData;
            NSMutableArray *transformerResults = [NSMutableArray new];
            for (NSDictionary *dict in lists) {
                if (![dict isKindOfClass:[NSDictionary class]]) continue;
                
                targetObject = [[[targetModel class] new] yy_modelWithDictionary:dict];
                [transformerResults addObject:targetObject];
            }
            return transformerResults;
        } else if ([rowData isKindOfClass:[NSDictionary class]]) {
            targetObject = [[[targetModel class] new] yy_modelWithDictionary:(NSDictionary *)rowData];
            return targetObject;
        }
    }
    
    return nil;
}

@end
