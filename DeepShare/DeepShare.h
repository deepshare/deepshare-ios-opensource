//
//  DeepShare.h
//  DeepShare
//
//  Created by johney.song on 15/2/26.
//  Copyright (c) 2015年 Singulariti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^callbackWithError) (NSError *error);
typedef void (^callbackWithParams) (NSDictionary *params, NSError *error);
typedef void (^callbackWithTaggedValue) (NSDictionary *taggToValue, NSError *error);
typedef void (^callbackWithNewUsageFromMe) (int newInstall, int newOpen, NSError *error);
@class DeepShare;

@protocol DeepShareDelegate <NSObject>

- (void)onInappDataReturned: (NSDictionary *) params withError: (NSError *) error;

@end

@interface DeepShare : NSObject
@property (nonatomic, weak) id <DeepShareDelegate> delegate;
/** 初始化API，同时设置相应的委托对象
 * @param appId APP注册时生成的APP ID.
 * @param options launchOptions AppDelegate的didFinishLaunchingWithOptions方法所传回的参数
 * @param delegate 委托方法onInappDataReturned所在的类的对象
 * @return void
 */
+ (void)initWithAppID:(NSString *)appId withLaunchOptions:(NSDictionary *)options withDelegate:(id)delegate;

/** 
 * 获取我的分享ID
 */
+ (NSString *)getSenderID;

/**
 * 获取channel信息
 */
+ (NSArray *)getInstallChannel;

/** 处理Apple-registered URL schemes
 * @param url 系统回调传回的URL
 * @return bool URL是否被成功识别处理
 */
+ (BOOL)handleURL:(NSURL *)url;

/** 让DeepShare通过NSUserActivity进行页面转换，成功则返回true，否则返回false
 * @param userActivity userActivity存储了页面跳转的信息，包括来源与目的页面
 */
+ (BOOL)continueUserActivity:(NSUserActivity *)userActivity;

/**
 * 改变指定价值标签的值
 * @param tagToValue 所指定价值标签和其增加或减少的价值量所组成的NSDictionary.
 */
+ (void)attribute:(NSDictionary *)tagToValue completion:(callbackWithError)callback;

/**
 * 异步返回通过我的分享带来的此应用的新使用，包括新安装的用户量和再次激活打开的用户量
 */
+ (void)getNewUsageFromMe:(callbackWithNewUsageFromMe)callback;

/**
 * 清空通过我的分享带来的此应用的新使用，包括新安装的用户量和再次激活打开的用户量
 */
+ (void)clearNewUsageFromMe:(callbackWithError)callback;

@end
