//
//  Deeplink.m
//  TestDeeplink
//
//  Created by johney.song on 15/2/26.
//  Copyright (c) 2015年 johney.song. All rights reserved.
//

#import "DeepShare.h"
#import "DLPreferenceHelper.h"
#import "DSError.h"
#import "DLSystemObserver.h"
#import "DSEncodingUtils.h"
#import "NewvalueChange.h"
#import "DeepShareImpl.h"

@implementation DeepShare

@synthesize delegate;

static DeepShareImpl *currInstance;

+ (void)initWithAppID:(NSString *)appId withLaunchOptions:(NSDictionary *)options withDelegate:(id)delegate{
    DeepShare *deepshare = [[DeepShare alloc] init];
    deepshare.delegate = delegate;
    [DLPreferenceHelper setAppKey:appId];
    if (!currInstance) {
        currInstance = [[DeepShareImpl alloc] init];
        [DeepShareImpl initInstance];
    }
    [DeepShareImpl getcurrInstance].sessionparamLoadCallback = ^(NSDictionary *params, NSError *error) {
        [delegate onInappDataReturned:params withError:error];
    };
    
    if ([DLSystemObserver getOSVersion].integerValue >= 9) {
        if (!([options objectForKey:UIApplicationLaunchOptionsURLKey] || [options objectForKey:UIApplicationLaunchOptionsUserActivityDictionaryKey])) {
            [[DeepShareImpl getcurrInstance] initUserSessionWithCallbackInternal:[DeepShareImpl getcurrInstance].sessionparamLoadCallback];
        }
    } else if (![options objectForKey:UIApplicationLaunchOptionsURLKey]) {
        [[DeepShareImpl getcurrInstance] initUserSessionWithCallbackInternal:[DeepShareImpl getcurrInstance].sessionparamLoadCallback];
    }
}

+ (NSString *)getSenderID{
    return [DLSystemObserver getUniqueId];
}

+ (NSArray *)getInstallChannel {
    NSArray *channel = [DLPreferenceHelper getInstalledChannels];
    return channel;
}

+ (void)attribute:(NSDictionary *)tagToValue completion:(callbackWithError)callback{
    if (![DeepShareImpl getcurrInstance].isInit) {
        NSDictionary *errorDict;
        errorDict = [DSError getUserInfoDictForDomain:DSInitFailedError];
        callback([NSError errorWithDomain:DSErrorDomain code:DSInitFailedError userInfo:errorDict]);
    } else {
        [[DeepShareImpl getcurrInstance] sendAttributeReqWithcallback:tagToValue andCallback:callback];
    }
}

+ (BOOL)handleURL:(NSURL *)url {
    BOOL handled = NO;
    if (url) {
        NSString *query = [url fragment];
        if (!query) {
            query = [url query];
        }
        
        NSDictionary *params = [DSEncodingUtils decodeQueryStringToDictionary:query];
        if ([params objectForKey:@"click_id"]) {
            handled = YES;
            [DLPreferenceHelper setLinkClickID:[params objectForKey:@"click_id"]];
        }
    }
    if ([DeepShareImpl getcurrInstance].sessionparamLoadCallback) {
        [[DeepShareImpl getcurrInstance] initUserSessionWithCallbackInternal:[DeepShareImpl getcurrInstance].sessionparamLoadCallback];
    }
    return handled;
}

+ (BOOL)continueUserActivity:(NSUserActivity *)userActivity {
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        [DLPreferenceHelper setUniversalLinkUrl:[userActivity.webpageURL absoluteString]];
        
        // parse wcookie if have
        NSString *query = [userActivity.webpageURL query];
        if (query) {
            NSDictionary *params = [DSEncodingUtils decodeQueryStringToDictionary:query];
            if ([params objectForKey:@"wcookie"]) {
                [DLPreferenceHelper setWCookie:[params objectForKey:@"wcookie"]];
            }
        }
        
        // parse the click_id
        NSRange range = [[userActivity.webpageURL absoluteString] rangeOfString:@"/" options:NSBackwardsSearch];
        if(range.location != NSNotFound) {
            NSString* str = [[DLPreferenceHelper getUniversalLinkUrl] substringFromIndex:(range.location + 1)];
            NSRange endRange = [str rangeOfString:@"?" options:NSBackwardsSearch];
            if(endRange.location != NSNotFound) {
                [DLPreferenceHelper setShortSeg: [str substringToIndex:endRange.location]];
            } else {
                [DLPreferenceHelper setShortSeg: [[DLPreferenceHelper getUniversalLinkUrl] substringFromIndex:(range.location + 1)]];
            }
            [[DeepShareImpl getcurrInstance] initUserSessionWithCallbackInternal:[DeepShareImpl getcurrInstance].sessionparamLoadCallback];
            //self.preferenceHelper.isContinuingUserActivity = NO;
            return [[userActivity.webpageURL absoluteString] containsString:DOMAIN_UNIVERSAL_LINK];
        } else {
            // wrong url format
            [[UIApplication sharedApplication] openURL:userActivity.webpageURL];
            return false;
        }
    }
    return true;
}

+ (void)getNewUsageFromMe:(callbackWithNewUsageFromMe)callback{
    if (![DeepShareImpl getcurrInstance].isInit) {
        NSDictionary *errorDict;
        errorDict = [DSError getUserInfoDictForDomain:DSInitFailedError];
        callback(0,0, [NSError errorWithDomain:DSErrorDomain code:DSInitFailedError userInfo:errorDict]);
    } else {
        [[DeepShareImpl getcurrInstance] getNewUsage:callback];
    }
}

+ (void)clearNewUsageFromMe:(callbackWithError)callback{
    if (![DeepShareImpl getcurrInstance].isInit) {
        NSDictionary *errorDict;
        errorDict = [DSError getUserInfoDictForDomain:DSInitFailedError];
        callback([NSError errorWithDomain:DSErrorDomain code:DSInitFailedError userInfo:errorDict]);
    } else {
        [[DeepShareImpl getcurrInstance] clearNewUsage:callback];
    }
}

@end
