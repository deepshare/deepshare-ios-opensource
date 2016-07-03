//
//  AppDelegate.m
//  TestDeeplink
//
//  Created by johney.song on 15/2/24.
//  Copyright (c) 2015年 johney.song. All rights reserved.
//

#import "AppDelegate.h"
#import "DeepShare.h"
#import "ViewController.h"


@interface AppDelegate ()
@end

@implementation AppDelegate

- (void)onInappDataReturned: (NSDictionary *) params withError: (NSError *) error {
    if (!error) {
        NSLog(@"finished init with params = %@", [params description]);
        [[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_PARAM_UPDATE object:nil userInfo:params];
    } else {
        NSString *errorString = [[error userInfo] objectForKey:NSLocalizedDescriptionKey];
        NSLog(@"init error id: %ld %@",(long)error.code, errorString);
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [DeepShare initWithAppID:@"f709f09576216199" withLaunchOptions:launchOptions withDelegate:self];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation {
    
    NSLog(@"opened app from URL %@", [url description]);
    if([DeepShare handleURL:url]){
        return YES;
    }
    
    return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary *)options {
    
    NSLog(@"opened app from URL %@", [url description]);
    if([DeepShare handleURL:url]){
        return YES;
    }
    
    return NO;
}

//To get rid a warning of "Attempting to load the view of a view controller while it is deallocating is not allowed and may result in undefined behavior (UIAlertController: 0x1245a0560)"
- (BOOL)application:(UIApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType{
    return true;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler {
    NSLog(@"continueUserActivity : %@", [userActivity.webpageURL absoluteString]);
    BOOL handledByDeepShare = [DeepShare continueUserActivity:userActivity];
    
    return handledByDeepShare;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
