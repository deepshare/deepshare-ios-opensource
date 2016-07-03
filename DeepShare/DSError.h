//
//  DSError.h
//  DeepShare
//
//  Created by johney.song on 15/3/3.
//   Copyright (c) 2015年 Singulariti. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const DSErrorDomain;

enum {
    /** 初始化错误，使用了错误的APPKEY会导致此错误*/
    DSInitError = 4000,
    /** 参数错误，参数为空*/
    DSArgumentEmptyError,
    /** 网络错误，网络连接异常*/
    DSNetError,
    /** 未初始化错误，initWithAppKey没有在程序启动时被调用会导致此错误*/
    DSNotInitError,
    /** 初始化错误，初始化失败*/
    DSInitFailedError,
    /** 未引用SafariService.framework*/
    DSNotReferenceSafariService
};

@interface DSError : NSObject

/** 获取对应错误码的详细信息
 @param code 错误码.
 @return NSDictionary 详细错误信息的Dictionary, key:“NSLocalizedDescriptionKey”对应此错误的描述信息
 */
+ (NSDictionary *)getUserInfoDictForDomain:(NSInteger)code;

@end
