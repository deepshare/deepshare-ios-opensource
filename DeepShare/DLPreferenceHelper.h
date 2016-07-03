//
//  DPPreferenceHelper.h
//  TestDeeplink
//
//  Created by johney.song on 15/2/26.
//  Copyright (c) 2015年 johney.song. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FILE_NAME   [[NSString stringWithUTF8String:__FILE__] lastPathComponent]
#define LINE_NUM    __LINE__

static NSString *NO_STRING_VALUE = @"dl_no_value";
static NSString *KEY_SESSION_ID = @"dl_session_id";
static NSString *KEY_IS_REFERRABLE = @"dl_is_referrable";

@interface DLPreferenceHelper : NSObject

+ (NSString *)getAPIBaseURL;
+ (NSString *)getAPIURL:(NSString *) endpoint;

+ (void)setTimeout:(NSInteger)timeout;
+ (NSInteger)getTimeout;

+ (void)setRetryInterval:(NSInteger)retryInterval;
+ (NSInteger)getRetryInterval;

+ (void)setRetryCount:(NSInteger)retryCount;
+ (NSInteger)getRetryCount;

+ (void)setAppKey:(NSString *)appKey;
+ (NSString *)getAppKey;

+ (void)setUserURL:(NSString *)userUrl;
+ (NSString *)getUserURL;

+ (void)setUniversalLinkUrl:(NSString *)universalLinkUrl;
+ (NSString *)getUniversalLinkUrl;

+ (void)setUniqueID:(NSString *)uniqueID;
+ (NSString *)getUniqueID;

+ (void)setLinkClickID:(NSString *)linkClickId;
+ (NSString *)getLinkClickID;

+ (void)setWCookie:(NSString *)wcookie;
+ (NSString *)getWCookie;

+ (void)setShortSeg:(NSString *)shortSegId;
+ (NSString *)getShortSeg;

+ (void)setSessionParams:(NSString *)sessionParams;
+ (NSString *)getSessionParams;

+ (void)setInstalledChannels:(NSArray *)channelParams;
+ (NSArray *)getInstalledChannels;

+ (void)setInstallParams:(NSString *)installParams;
+ (NSString *)getInstallParams;

+ (void)setInstall:(NSString *)status;
+ (BOOL)getInstall;

+ (void)setFlagIfInstalledApp:(NSString *)flag;
+ (NSString *)getFlagIfInstalledApp;


+ (NSString *)base64EncodeStringToString:(NSString *)strData;
+ (NSString *)base64DecodeStringToString:(NSString *)strData;

+ (void)setDebug;
+ (void)clearDebug;
+ (BOOL)isDebug;

+ (void)log:(NSString *)filename line:(int)line message:(NSString *)format, ...;

@end
