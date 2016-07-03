//
//  DSEncodingUtils.m
//  DeepShareSample
//
//  Created by johney.song on 15/4/8.
//  Copyright (c) 2015年 johney.song. All rights reserved.
//

#import "DSEncodingUtils.h"
#import "DLPreferenceHelper.h"

@implementation DSEncodingUtils

+ (NSDictionary *)decodeQueryStringToDictionary:(NSString *)queryString {
    NSArray *pairs = [queryString componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        if (kv.count > 1) { // If this key has a value (so, not foo&bar=...)
            NSString *key = kv[0];
            NSString *val = [kv[1] stringByRemovingPercentEncoding];
            
            // Don't add empty items
            if (val.length) {
                params[key] = val;
            }
        }
    }
    
    return params;
}

+ (NSDictionary *)convertParamsStringToDictionary:(NSString *)paramsString {
    if (![paramsString isEqualToString:NO_STRING_VALUE]) {
        NSData *tempData = [paramsString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *params = [NSJSONSerialization JSONObjectWithData:tempData options:0 error:nil];
        if (!params) {
            NSString *decodedVersion = [DLPreferenceHelper base64DecodeStringToString:paramsString];
            tempData = [decodedVersion dataUsingEncoding:NSUTF8StringEncoding];
            params = [NSJSONSerialization JSONObjectWithData:tempData options:0 error:nil];
            if (!params) {
                params = [[NSDictionary alloc] init];
            }
        }
        return params;
    }
    return [[NSDictionary alloc] init];
}

@end
