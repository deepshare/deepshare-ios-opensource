//
//  DLSystemObserver.h
//  TestDeeplink
//
//  Created by johney.song on 15/3/1.
//  Copyright (c) 2015年 johney.song. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLSystemObserver : NSObject

+ (NSString *)getHardwareId;
+ (NSString *)getUniqueId;
+ (NSString *)getURIScheme;
+ (NSString *)getAppVersion;
+ (NSString *)getAppBuildVersion;
+ (NSString *)getCarrier;
+ (NSString *)getBrand;
+ (NSString *)getModel;
+ (NSString *)getOS;
+ (NSString *)getOSVersion;
+ (NSNumber *)getScreenWidth;
+ (NSNumber *)getScreenHeight;
+ (NSNumber *)getScreendpi;
+ (NSString *)getDeviceName;
+ (BOOL)isSimulator;
+ (NSString *)getbluetoothversion;
+ (BOOL)hasnfc;

@end
