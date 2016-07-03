//
//  DPPreferenceHelper.m
//  TestDeeplink
//
//  Created by johney.song on 15/2/26.
//  Copyright (c) 2015年 johney.song. All rights reserved.
//

#import "DLPreferenceHelper.h"
#import "DLServerInterface.h"
#import "DLConfig.h"

static const NSInteger DEFAULT_TIMEOUT = 3;
static const NSInteger RETRY_INTERVAL = 3;
static const NSInteger MAX_RETRIES = 1;

static NSString *KEY_APP_KEY = @"dl_app_key";
static NSString *KEY_DEVICE_FINGERPRINT_ID = @"dl_device_fingerprint_id";
static NSString *KEY_LINK_CLICK_IDENTIFIER = @"dl_link_click_identifier";
static NSString *KEY_UNIVERSAL_LINK_URL = @"dl_universal_link_url";
static NSString *KEY_FLAG_INSTALL = @"dl_install_app_flag";
static NSString *KEY_LINK_CLICK_ID = @"dl_link_click_id";
static NSString *KEY_WCOOKIE_ID = @"dl_w_cookie_id";
static NSString *KEY_SHORT_SEG_ID = @"dl_short_seg_id";
static NSString *KEY_IDENTITY_ID = @"dl_identity_id";
static NSString *KEY_IDENTITY = @"dl_identity";
static NSString *KEY_SESSION_PARAMS = @"dl_session_params";
static NSString *KEY_CHANNEL_PARAMS = @"dl_channel_params";
static NSString *KEY_INSTALL_PARAMS = @"dl_install_params";
static NSString *KEY_USER_URL = @"dl_user_url";
static NSString *KEY_TIMEOUT = @"dl_timeout";
static NSString *KEY_RETRY_INTERVAL = @"dl_retry_interval";
static NSString *KEY_RETRY_COUNT = @"dl_retry_count";
static NSString *KEY_TAG_VALUE = @"dl_tag_value";
static NSString *KEY_UNIQUE_ID = @"unique_id";
static NSString *KEY_INSTALL = @"install";

static DLPreferenceHelper *instance = nil;
static BOOL DL_Debug = NO;
static BOOL DL_Remote_Debug = NO;
static dispatch_queue_t dl_asyncLogQueue = nil;
static DLServerInterface *serverInterface = nil;

@interface DLPreferenceHelper() <DLServerInterfaceDelegate>

@end

@implementation DLPreferenceHelper

+ (void)setAppKey:(NSString *)appKey {
    [DLPreferenceHelper writeObjectToDefaults:KEY_APP_KEY value:appKey];
}

+ (NSString *)getAppKey {
    NSString *ret = (NSString *)[DLPreferenceHelper readObjectFromDefaults:KEY_APP_KEY];
    if (!ret){
        ret = NO_STRING_VALUE;
    }
    return ret;
}

+ (void)writeObjectToDefaults:(NSString *)key value:(NSObject *)value
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];
    [defaults synchronize];
}

+ (void)setUniqueID:(NSString *)uniqueID {
    [DLPreferenceHelper writeObjectToDefaults:KEY_UNIQUE_ID value:uniqueID];
}

+ (NSString *)getUniqueID {
    NSString *ret = (NSString *)[DLPreferenceHelper readObjectFromDefaults:KEY_UNIQUE_ID];
    if (!ret){
        ret = NO_STRING_VALUE;
    }
    return ret;
}

+ (void)setInstall:(NSString *)status {
    [DLPreferenceHelper writeObjectToDefaults:KEY_INSTALL value:status];
}

+ (BOOL)getInstall {
    NSString *ret = (NSString *)[DLPreferenceHelper readObjectFromDefaults:KEY_INSTALL];
    if ([ret isEqualToString:@"installed"]){
        return true;
    } else {
        return false;
    }
}

+ (void)setLinkClickID:(NSString *)linkClickId {
    [DLPreferenceHelper writeObjectToDefaults:KEY_LINK_CLICK_ID value:linkClickId];
}

+ (NSString *)getLinkClickID {
    NSString *ret = (NSString *)[DLPreferenceHelper readObjectFromDefaults:KEY_LINK_CLICK_ID];
    if (!ret)
        ret = NO_STRING_VALUE;
    return ret;
}

+ (void)setWCookie:(NSString *)wcookie {
    [DLPreferenceHelper writeObjectToDefaults:KEY_WCOOKIE_ID value:wcookie];
}

+ (NSString *)getWCookie {
    NSString *ret = (NSString *)[DLPreferenceHelper readObjectFromDefaults:KEY_WCOOKIE_ID];
    if (!ret)
        ret = NO_STRING_VALUE;
    return ret;
}

+ (void)setShortSeg:(NSString *)shortSegId {
    [DLPreferenceHelper writeObjectToDefaults:KEY_SHORT_SEG_ID value:shortSegId];
}

+ (NSString *)getShortSeg {
    NSString *ret = (NSString *)[DLPreferenceHelper readObjectFromDefaults:KEY_SHORT_SEG_ID];
    if (!ret)
        ret = NO_STRING_VALUE;
    return ret;
}

+ (void)setDebug {
    DL_Debug = YES;
    
    if (!instance) {
        instance = [[DLPreferenceHelper alloc] init];
        serverInterface = [[DLServerInterface alloc] init];
        serverInterface.delegate = instance;
        dl_asyncLogQueue = dispatch_queue_create("dl_log_queue", NULL);
    }
    
}

+ (void)clearDebug {
    DL_Debug = NO;
    
    if (DL_Remote_Debug) {
        DL_Remote_Debug = NO;
        
    }
}

+ (BOOL)isDebug {
    return DL_Debug;
}

+ (NSString *)getAPIBaseURL {
    return [NSString stringWithFormat:@"%@/%@/", DL_API_BASE_URL, DL_API_VERSION];
}

+ (NSString *)getAPIURL:(NSString *) endpoint {
    return [[DLPreferenceHelper getAPIBaseURL] stringByAppendingString:endpoint];
}

+ (void)setTimeout:(NSInteger)timeout {
    [DLPreferenceHelper writeIntegerToDefaults:KEY_TIMEOUT value:timeout];
}

+ (NSInteger)getTimeout {
    NSInteger timeout = [DLPreferenceHelper readIntegerFromDefaults:KEY_TIMEOUT];
    if (timeout <= 0) {
        timeout = DEFAULT_TIMEOUT;
    }
    return timeout;
}

+ (void)setRetryInterval:(NSInteger)retryInterval {
    [DLPreferenceHelper writeIntegerToDefaults:KEY_RETRY_INTERVAL value:retryInterval];
}

+ (NSInteger)getRetryInterval {
    NSInteger retryInt = [DLPreferenceHelper readIntegerFromDefaults:KEY_RETRY_INTERVAL];
    if (retryInt <= 0) {
        retryInt = RETRY_INTERVAL;
    }
    return retryInt;
}

+ (void)setRetryCount:(NSInteger)retryCount {
    [DLPreferenceHelper writeIntegerToDefaults:KEY_RETRY_COUNT value:retryCount];
}

+ (NSInteger)getRetryCount {
    NSInteger retryCount = [DLPreferenceHelper readIntegerFromDefaults:KEY_RETRY_COUNT];
    if (retryCount <= 0) {
        retryCount = MAX_RETRIES;
    }
    return retryCount;
}

+ (void)setUserURL:(NSString *)userUrl {
    [DLPreferenceHelper writeObjectToDefaults:KEY_USER_URL value:userUrl];
}

+ (NSString *)getUserURL {
    NSString *ret = (NSString *)[DLPreferenceHelper readObjectFromDefaults:KEY_USER_URL];
    if (!ret)
        ret = NO_STRING_VALUE;
    return ret;
}

+ (void)setUniversalLinkUrl:(NSString *)universalLinkUrl {
    [DLPreferenceHelper writeObjectToDefaults:KEY_UNIVERSAL_LINK_URL value:universalLinkUrl];
}

+ (NSString *)getUniversalLinkUrl {
    NSString *ret = (NSString *)[DLPreferenceHelper readObjectFromDefaults:KEY_UNIVERSAL_LINK_URL];
    if (!ret)
        ret = NO_STRING_VALUE;
    return ret;
}

+ (void)setFlagIfInstalledApp:(NSString *)flag {
    [DLPreferenceHelper writeObjectToDefaults:KEY_FLAG_INSTALL value:flag];
}

+ (NSString *)getFlagIfInstalledApp {
    NSString *ret = (NSString *)[DLPreferenceHelper readObjectFromDefaults:KEY_FLAG_INSTALL];
    if (!ret)
        ret = NO_STRING_VALUE;
    return ret;
}

+ (void)setSessionParams:(NSString *)sessionParams {
    [DLPreferenceHelper writeObjectToDefaults:KEY_SESSION_PARAMS value:sessionParams];
}

+ (NSString *)getSessionParams {
    NSString *ret = (NSString *)[DLPreferenceHelper readObjectFromDefaults:KEY_SESSION_PARAMS];
    if (!ret)
        ret = NO_STRING_VALUE;
    return ret;
}

+ (void)setInstalledChannels:(NSArray *)channelParams {
    [DLPreferenceHelper writeObjectToDefaults:KEY_CHANNEL_PARAMS value:channelParams];
}

+ (NSArray *)getInstalledChannels {
    NSArray *ret = (NSArray *)[DLPreferenceHelper readObjectFromDefaults:KEY_CHANNEL_PARAMS];
    if (!ret)
        ret = [[NSArray alloc] init];
    return ret;
}

+ (void)setInstallParams:(NSString *)installParams {
    [DLPreferenceHelper writeObjectToDefaults:KEY_INSTALL_PARAMS value:installParams];
}

+ (NSString *)getInstallParams {
    NSString *ret = (NSString *)[DLPreferenceHelper readObjectFromDefaults:KEY_INSTALL_PARAMS];
    if (!ret)
        ret = NO_STRING_VALUE;
    return ret;
}

+ (NSObject *)readObjectFromDefaults:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSObject *obj = [defaults objectForKey:key];
    return obj;
}

+ (void)writeIntegerToDefaults:(NSString *)key value:(NSInteger)value
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:value forKey:key];
    [defaults synchronize];
}

+ (NSInteger)readIntegerFromDefaults:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger integ = [defaults integerForKey:key];
    return integ;
}

+ (void)log:(NSString *)filename line:(int)line message:(NSString *)format, ... {
    if (DL_Debug) {
        va_list args;
        va_start(args, format);
        NSString *log = [NSString stringWithFormat:@"[%@:%d] %@", filename, line, [[NSString alloc] initWithFormat:format arguments:args]];
        va_end(args);
        NSLog(@"%@", log);
        
    }
}

// BASE 64 CRAP found on http://ios-dev-blog.com/base64-encodingdecoding/

static const char _base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const short _base64DecodingTable[256] = {
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -1, -1, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
    -2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
    -2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
};

+ (NSString *)base64EncodeStringToString:(NSString *)strData {
    return [self base64EncodeData:[strData dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSString *)base64DecodeStringToString:(NSString *)strData {
    return [[NSString alloc] initWithData:[DLPreferenceHelper base64DecodeString:strData] encoding:NSUTF8StringEncoding];
}

+ (NSString *)base64EncodeData:(NSData *)objData {
    const unsigned char * objRawData = [objData bytes];
    char * objPointer;
    char * strResult;
    
    // Get the Raw Data length and ensure we actually have data
    long intLength = [objData length];
    if (intLength == 0) return nil;
    
    // Setup the String-based Result placeholder and pointer within that placeholder
    strResult = (char *)calloc(((intLength + 2) / 3) * 4, sizeof(char));
    objPointer = strResult;
    
    // Iterate through everything
    while (intLength > 2) { // keep going until we have less than 24 bits
        *objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
        *objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
        *objPointer++ = _base64EncodingTable[((objRawData[1] & 0x0f) << 2) + (objRawData[2] >> 6)];
        *objPointer++ = _base64EncodingTable[objRawData[2] & 0x3f];
        
        // we just handled 3 octets (24 bits) of data
        objRawData += 3;
        intLength -= 3;
    }
    
    // now deal with the tail end of things
    if (intLength != 0) {
        *objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
        if (intLength > 1) {
            *objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
            *objPointer++ = _base64EncodingTable[(objRawData[1] & 0x0f) << 2];
            *objPointer++ = '=';
        } else {
            *objPointer++ = _base64EncodingTable[(objRawData[0] & 0x03) << 4];
            *objPointer++ = '=';
            *objPointer++ = '=';
        }
    }
    
    // Terminate the string-based result
    *objPointer = '\0';
    
    NSString *retString = [NSString stringWithCString:strResult encoding:NSASCIIStringEncoding];
    free(strResult);
    
    // Return the results as an NSString object
    return retString;
}

+ (NSData *)base64DecodeString:(NSString *)strBase64 {
    const char * objPointer = [strBase64 cStringUsingEncoding:NSASCIIStringEncoding];
    long intLength = strlen(objPointer);
    int intCurrent;
    int i = 0, j = 0, k;
    
    char * objResult;
    objResult = calloc(intLength, sizeof(char));
    
    // Run through the whole string, converting as we go
    while ( ((intCurrent = *objPointer++) != '\0') && (intLength-- > 0) ) {
        if (intCurrent == '=') {
            if (*objPointer != '=' && ((i % 4) == 1)) {// || (intLength > 0)) {
                // the padding character is invalid at this point -- so this entire string is invalid
                free(objResult);
                return nil;
            }
            continue;
        }
        
        intCurrent = _base64DecodingTable[intCurrent];
        if (intCurrent == -1) {
            // we're at a whitespace -- simply skip over
            continue;
        } else if (intCurrent == -2) {
            // we're at an invalid character
            free(objResult);
            return nil;
        }
        
        switch (i % 4) {
            case 0:
                objResult[j] = intCurrent << 2;
                break;
                
            case 1:
                objResult[j++] |= intCurrent >> 4;
                objResult[j] = (intCurrent & 0x0f) << 4;
                break;
                
            case 2:
                objResult[j++] |= intCurrent >>2;
                objResult[j] = (intCurrent & 0x03) << 6;
                break;
                
            case 3:
                objResult[j++] |= intCurrent;
                break;
        }
        i++;
    }
    
    // mop things up if we ended on a boundary
    k = j;
    if (intCurrent == '=') {
        switch (i % 4) {
            case 1:
                // Invalid state
                free(objResult);
                return nil;
                
            case 2:
                k++;
                // flow through
            case 3:
                objResult[k] = 0;
        }
    }
    
    // Cleanup and setup the return NSData
    NSData * objData = [[NSData alloc] initWithBytes:objResult length:j] ;
    free(objResult);
    return objData;
}


@end
