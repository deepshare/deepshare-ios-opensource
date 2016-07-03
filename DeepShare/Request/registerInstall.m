//
//  registerInstall.m
//  DeepShareSample
//
//  Created by Hibbert on 15/10/14.
//  Copyright © 2015年 johney.song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "registerInstall.h"
#import "DLPreferenceHelper.h"
#import "DLServerInterface.h"
#import "DLSystemObserver.h"
#import "DSEncodingUtils.h"
#import "DLTime.h"

@interface registerInstall()

@property (strong, nonatomic) callbackWithParams callback;
@property (nonatomic) double starttime;

@end

@implementation registerInstall

- (void) setcallback: (callbackWithParams) callback {
    self.callback = callback;
}

- (NSString *) typeofRequest {
    return @"inappdata";
}

- (NSString *) message {
    return @"calling register install";
}

- (void) processResponsewithError: (NSError *) error {
    [DLPreferenceHelper setShortSeg:NO_STRING_VALUE];
    
    self.callback(nil, error);
    double time = CACurrentMediaTime() - self.starttime;
    [DLTime addtimestamp:[self typeofRequest] withtime:time];

}

- (void) processResponse: (DLServerResponse *) response {
    [DLPreferenceHelper setInstall:@"installed"];
    
    if ([response.data objectForKey:@"inapp_data"]) {
        [DLPreferenceHelper setSessionParams:[response.data objectForKey:@"inapp_data"]];
    } else {
        [DLPreferenceHelper setSessionParams:NO_STRING_VALUE];
    }
    
    if ([response.data objectForKey:@"channels"]) {
        [DLPreferenceHelper setInstalledChannels:[response.data objectForKey:@"channels"]];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.callback) self.callback([self getLatestReferringParams], nil);
        double time = CACurrentMediaTime() - self.starttime;
        [DLTime addtimestamp:[self typeofRequest] withtime:time];
    });
    
}

- (NSDictionary *)getLatestReferringParams {
    NSString *storedParam = [DLPreferenceHelper getSessionParams];
    return [DSEncodingUtils convertParamsStringToDictionary:storedParam];
}

- (BOOL) sendRequest: (DLServerInterface *) serverInterface withcallback: (Servercallback) callback {
    self.starttime = CACurrentMediaTime();
    NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
    BOOL is_newuser = true;
    [post setObject:[NSNumber numberWithBool:is_newuser] forKey:@"is_newuser"];
    if (![[[NSBundle mainBundle] objectForInfoDictionaryKey:IDFA_DISABLE] boolValue]) {
        if ([DLSystemObserver getHardwareId]) {
            [post setObject:[DLSystemObserver getHardwareId] forKey:@"hardware_id"];
        }
    }
    [post setObject:[DLSystemObserver getUniqueId] forKey:@"unique_id"];
    if ([DLSystemObserver getAppVersion]) [post setObject:[DLSystemObserver getAppVersion] forKey:@"app_version_name"];
    if ([DLSystemObserver getAppBuildVersion]) {
        [post setObject:[DLSystemObserver getAppBuildVersion] forKey:@"app_version_build"];
    }
    [post setObject:[NSString stringWithFormat:@"ios%@", SDK_VERSION] forKey:@"sdk_info"];
    if ([DLSystemObserver getCarrier]) {
        [post setObject:[DLSystemObserver getCarrier] forKey:@"carrier_name"];
    }
    if ([DLSystemObserver getModel]) {
        [post setObject:[DLSystemObserver getModel] forKey:@"model"];
    }
    if ([DLSystemObserver getBrand]) {
        [post setObject:[DLSystemObserver getBrand] forKey:@"brand"];
    }
    [post setObject:[NSNumber numberWithBool:[DLSystemObserver isSimulator]] forKey:@"is_emulator"];
    if ([DLSystemObserver getOS]) [post setObject:[DLSystemObserver getOS] forKey:@"os"];
    if ([DLSystemObserver getOSVersion]) [post setObject:[DLSystemObserver getOSVersion] forKey:@"os_version"];
    [post setObject:[NSNumber numberWithBool:[DLSystemObserver hasnfc]] forKey:@"has_nfc"];
    if ([DLSystemObserver getbluetoothversion]) {
        [post setObject:[DLSystemObserver getbluetoothversion] forKey:@"bluetooth_version"];
    }
    [post setObject:[DLSystemObserver getScreendpi] forKey:@"screen_dpi"];
    if ([DLSystemObserver getScreenWidth]) [post setObject:[DLSystemObserver getScreenWidth] forKey:@"screen_width"];
    if ([DLSystemObserver getScreenHeight]) [post setObject:[DLSystemObserver getScreenHeight] forKey:@"screen_height"];
    
    [serverInterface postRequestAsync:post url:[DLPreferenceHelper getAPIURL:[NSString stringWithFormat:@"%@/%@", [self typeofRequest], [DLPreferenceHelper getAppKey]]] andTag:self.tag withcallback: callback];
    return true;
}

@end
