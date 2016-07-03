//
//  DSEncodingUtils.h
//  DeepShareSample
//
//  Created by johney.song on 15/4/8.
//  Copyright (c) 2015年 johney.song. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSEncodingUtils : NSObject

+ (NSDictionary *)decodeQueryStringToDictionary:(NSString *)queryString;
+ (NSDictionary *)convertParamsStringToDictionary:(NSString *)paramsString;

@end
