//
//  DeepShareImpl.h
//  DeepShareSample
//
//  Created by Hibbert on 15/10/16.
//  Copyright © 2015年 johney.song. All rights reserved.
//

#import "DeepShare.h"
#import "DLPreferenceHelper.h"
#import "DLServerInterface.h"
#import "DLServerRequest.h"
#import "DLServerRequestQueue.h"
#import "UIViewController+DLDebugging.h"
#import "DLConfig.h"
#import "DSError.h"
#import "DLSystemObserver.h"
#import "DSEncodingUtils.h"
#import "DLParam.h"

@interface DeepShareImpl : NSObject

@property (strong, nonatomic) NSTimer *sessionTimer;
@property (strong, nonatomic) DLServerRequestQueue *requestQueue;
@property (nonatomic) dispatch_semaphore_t processing_sema;
@property (nonatomic) dispatch_queue_t asyncQueue;
@property (nonatomic) NSInteger retryCount;
@property (nonatomic) NSInteger networkCount;
@property (strong, nonatomic) callbackWithParams sessionparamLoadCallback;
@property (assign, nonatomic) BOOL hasNetwork;
@property (assign, nonatomic) BOOL isInit;

+ (void)initInstance;
+ (DeepShareImpl *) getcurrInstance;
- (NSDictionary *)sanitizeQuotesFromInput:(NSDictionary *)input;
- (void)initUserSessionWithCallbackInternal:(callbackWithParams)callback;
- (void)processNextQueueItem;
- (void)handleFailure:(unsigned int)index witherror: (NSError *) error;
-(void)checkIfDeviceInstalledApp:(NSString *)deviceId;
-(void)sendInstallOrOpenReq:(NSString *)tag withcallback: (callbackWithParams)callback;
-(void)sendAttributeReqWithcallback:(NSDictionary *)tagToValue andCallback:(callbackWithError)callback;
-(void)getNewUsage:(callbackWithNewUsageFromMe)callback;
-(void)clearNewUsage:(callbackWithError)callback;

@end