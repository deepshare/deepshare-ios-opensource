//
//  DLSystemObserver.m
//  TestDeeplink
//
//  Created by johney.song on 15/3/1.
//  Copyright (c) 2015年 johney.song. All rights reserved.
//

#import "DLSystemObserver.h"
#include <sys/utsname.h>
#import "DLPreferenceHelper.h"
#import <UIKit/UIDevice.h>
#import <UIKit/UIScreen.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "DLConfig.h"

@implementation DLSystemObserver
+ (NSString *)getHardwareId {
    NSString *uid = nil;
    Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (ASIdentifierManagerClass) {
        SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
        id sharedManager = ((id (*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(ASIdentifierManagerClass, sharedManagerSelector);
        SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
        NSUUID *uuid = ((NSUUID* (*)(id, SEL))[sharedManager methodForSelector:advertisingIdentifierSelector])(sharedManager, advertisingIdentifierSelector);
        uid = [uuid UUIDString];
    }
    return uid;
}

+ (NSString *)getUniqueId {
    if ([[DLPreferenceHelper getUniqueID] isEqualToString:NO_STRING_VALUE]) {
        if (![[[NSBundle mainBundle] objectForInfoDictionaryKey:IDFA_DISABLE] boolValue]) {
            NSString *hardwareId = [DLSystemObserver getHardwareId];
            if (hardwareId) {
                [DLPreferenceHelper setUniqueID:hardwareId];
            }
        }
        if ([[DLPreferenceHelper getUniqueID] isEqualToString:NO_STRING_VALUE])  {
            if (NSClassFromString(@"UIDevice")) {
                [DLPreferenceHelper setUniqueID:[[UIDevice currentDevice].identifierForVendor UUIDString]];
            } else {
                [DLPreferenceHelper setUniqueID:[[NSUUID UUID] UUIDString]];
            }
        }
    }
    
    return [DLPreferenceHelper getUniqueID];
}

+ (NSString *)getURIScheme {
    NSArray *urlTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    if (urlTypes) {
        for (NSDictionary *urlType in urlTypes) {
            NSArray *urlSchemes = [urlType objectForKey:@"CFBundleURLSchemes"];
            if (urlSchemes) {
                for (NSString *urlScheme in urlSchemes) {
                    if (![[urlScheme substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"fb"] &&
                        ![[urlScheme substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"db"] &&
                        ![[urlScheme substringWithRange:NSMakeRange(0, 3)] isEqualToString:@"pin"]) {
                        return urlScheme;
                    }
                }
            }
        }
    }
    return nil;
}

+ (NSString *)getAppVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)getAppBuildVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (NSString *)getCarrier {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    return carrier.carrierName;
}

+ (NSString *)getBrand {
    return @"Apple";
}

+ (NSString *)getModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (BOOL)isSimulator {
    UIDevice *currentDevice = [UIDevice currentDevice];
    return [currentDevice.model rangeOfString:@"Simulator"].location != NSNotFound;
}

+ (NSString *)getDeviceName {
    if ([DLSystemObserver isSimulator]) {
        struct utsname name;
        uname(&name);
        return [NSString stringWithFormat:@"%@ %s", [[UIDevice currentDevice] name], name.nodename];
    } else {
        return [[UIDevice currentDevice] name];
    }
}

+ (NSString *)getOS {
    return @"iOS";
}

+ (NSString *)getOSVersion {
    UIDevice *device = [UIDevice currentDevice];
    return [device systemVersion];
}

+ (NSNumber *)getScreenWidth {
    UIScreen *mainScreen = [UIScreen mainScreen];
    float scaleFactor = mainScreen.scale;
    CGFloat width = mainScreen.bounds.size.width * scaleFactor;
    return [NSNumber numberWithInteger:(NSInteger)width];
}

+ (NSNumber *)getScreenHeight {
    UIScreen *mainScreen = [UIScreen mainScreen];
    float scaleFactor = mainScreen.scale;
    CGFloat height = mainScreen.bounds.size.height * scaleFactor;
    return [NSNumber numberWithInteger:(NSInteger)height];
}

+ (NSNumber *)getScreendpi {
    float scale = 1;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scale = [[UIScreen mainScreen] scale];
    }
    float dpi;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        dpi = 132 * scale;
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        dpi = 163 * scale;
    } else {
        dpi = 160 * scale;
    }
    return [NSNumber numberWithFloat: dpi];
}

+ (BOOL)hasnfc {
    NSString *device_version = [self getModel];
    if ([device_version isEqualToString:@"iPhone7,1"]||[device_version isEqualToString:@"iPhone7,2"]||[device_version isEqualToString:@"iPhone8,1"]||[device_version isEqualToString:@"iPhone8,2"]) {
        return true;
    } else {
        return false;
    }
}

+ (NSString *)getbluetoothversion {
    NSString *device_version = [self getModel];
    if ([device_version isEqualToString:@"iPhone1,1"]||[device_version isEqualToString:@"iPhone1,2"]) {
        return @"Bluetooth 2.0";
    } else if ([device_version isEqualToString:@"iPhone2,1"]||[device_version isEqualToString:@"iPhone3,1"]||[device_version isEqualToString:@"iPhone3,3"]) {
        return @"Bluetooth 2.1";
    } else if ([device_version isEqualToString:@"iPhone4,1"]||[device_version isEqualToString:@"iPhone5,1"]||[device_version isEqualToString:@"iPhone5,2"]||[device_version isEqualToString:@"iPhone5,3"]||[device_version isEqualToString:@"iPhone5,4"]||[device_version isEqualToString:@"iPhone6,1"]||[device_version isEqualToString:@"iPhone6,2"]) {
        return @"Bluetooth 4.0";
    } else if ([device_version isEqualToString:@"iPhone7,1"]||[device_version isEqualToString:@"iPhone7,2"]||[device_version isEqualToString:@"iPhone8,1"]||[device_version isEqualToString:@"iPhone8,2"]) {
        return @"Bluetooth 4.2";
    } else {
        return @"unknown";
    }
}

@end
