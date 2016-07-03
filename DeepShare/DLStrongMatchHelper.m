//
//  DLStrongMatchHelper.m
//  DeepShareSample
//
//  Created by 赵海 on 15/10/10.
//  Copyright © 2015年 johney.song. All rights reserved.
//

#import "DLStrongMatchHelper.h"
#import "DLConfig.h"
#import "DLPreferenceHelper.h"
#import "DLSystemObserver.h"
#import "DLViewController.h"
@import SafariServices;

#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED < 90000

@implementation DLStrongMatchHelper

+ (DLStrongMatchHelper *)strongMatchHelper { return nil; }
- (void)createStrongMatchWithBranchKey { }

@end

#else

@interface DLStrongMatchHelper ()

@property (strong, nonatomic) UIWindow *secondWindow;
@property (assign, nonatomic) BOOL requestInProgress;

@end

@implementation DLStrongMatchHelper

+ (DLStrongMatchHelper *)strongMatchHelper {
    static DLStrongMatchHelper *strongMatchHelper;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        strongMatchHelper = [[DLStrongMatchHelper alloc] init];
    });
    
    return strongMatchHelper;
}

- (void)createStrongMatchWithDeviceId:(NSString *)deviceId tag:(NSString *)tag withcallback: (callbackWithParams)callback {
    if (self.requestInProgress) {
        return;
    }
    
    self.requestInProgress = YES;
    
    [self presentSafariVCWithDeviceId:deviceId tag:tag withcallback:callback];
}

- (void)presentSafariVCWithDeviceId:(NSString *)deviceId tag:(NSString *)tag withcallback: (callbackWithParams)callback {
    NSMutableString *urlString = [[NSMutableString alloc] initWithFormat:@"%@/v2/binddevicetocookie/%@", DL_API_BASE_URL, deviceId];
    
    Class SFSafariViewControllerClass = NSClassFromString(@"SFSafariViewController");
    if (SFSafariViewControllerClass) {
        if ([tag isEqualToString:REQ_TAG_REGISTER_INSTALL]) {
            id safController = [[SFSafariViewControllerClass alloc] initWithURL:[NSURL URLWithString:urlString]];
            DLViewController *windowRootController = [[DLViewController alloc] init];
            //self.secondWindow = [[UIWindow alloc] initWithFrame:CGRectZero];
            self.secondWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
            self.secondWindow.rootViewController = windowRootController;
            [self.secondWindow makeKeyAndVisible];
            [self.secondWindow setAlpha:0];
            self.secondWindow.hidden = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [windowRootController presentViewController:safController animated:YES completion:^{
                    // Give a little bit of time for safari to load the request.
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.secondWindow.rootViewController dismissViewControllerAnimated:NO completion:NULL];
                        self.requestInProgress = NO;
                        [self.secondWindow removeFromSuperview];
                        self.secondWindow = nil;
                        // open or install request here, to make sure the time series
                        [[DeepShareImpl getcurrInstance] sendInstallOrOpenReq:tag withcallback:callback];
                    });
                }];
            });
        }else if ([tag isEqualToString:REQ_TAG_REGISTER_OPEN] && [[DLPreferenceHelper getFlagIfInstalledApp] isEqualToString:NO_STRING_VALUE]) {
            // send cookie in background thread
            id safController = [[SFSafariViewControllerClass alloc] initWithURL:[NSURL URLWithString:urlString]];
            DLViewController *windowRootController = [[DLViewController alloc] init];
            //self.secondWindow = [[UIWindow alloc] initWithFrame:CGRectZero];
            self.secondWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
            self.secondWindow.rootViewController = windowRootController;
            [self.secondWindow makeKeyAndVisible];
            [self.secondWindow setAlpha:0];
            self.secondWindow.hidden = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [windowRootController presentViewController:safController animated:YES completion:^{
                    //[NSThread sleepForTimeInterval:2];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.secondWindow.rootViewController dismissViewControllerAnimated:NO completion:NULL];
                        self.requestInProgress = NO;
                        [self.secondWindow removeFromSuperview];
                        self.secondWindow = nil;
                    });
                }];
                
            });
        }
    }
    else {
        NSDictionary *errorDict;
        errorDict = [DSError getUserInfoDictForDomain:DSNotReferenceSafariService];
        callback(nil, [NSError errorWithDomain:DSErrorDomain code:DSNotReferenceSafariService userInfo:errorDict]);
        self.requestInProgress = NO;
    }
}

@end

#endif