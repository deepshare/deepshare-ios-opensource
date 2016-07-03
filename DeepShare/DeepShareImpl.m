//
//  DeepShareImpl.m
//  DeepShareSample
//
//  Created by Hibbert on 15/10/16.
//  Copyright © 2015年 johney.song. All rights reserved.
//

#import "DeepShareImpl.h"
#import "registerInstall.h"
#import "registerOpen.h"
#import "CallClose.h"
#import "NewvalueChange.h"
#import "getNewUsage.h"
#import "clearNewUsage.h"
#import "DLStrongMatchHelper.h"

@interface DeepShareImpl() <DLServerInterfaceDelegate>

@property (strong, nonatomic) DLServerInterface *bServerInterface;

@end

@implementation DeepShareImpl

static DeepShareImpl *currInstance;

+ (DeepShareImpl *) getcurrInstance {
    return currInstance;
}

+ (void)initInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currInstance = [[DeepShareImpl alloc] init];
        currInstance.bServerInterface = [[DLServerInterface alloc] init];
        currInstance.isInit = NO;
        currInstance.bServerInterface.delegate = currInstance;
        currInstance.processing_sema = dispatch_semaphore_create(1);
        currInstance.asyncQueue = dispatch_queue_create("deeplink_request_queue", NULL);
        currInstance.requestQueue = [DLServerRequestQueue getInstance];
        currInstance.hasNetwork = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:currInstance
                                                 selector:@selector(callClose)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        
        currInstance.retryCount = 0;
        currInstance.networkCount = 0;
    });
}

- (NSDictionary *)sanitizeQuotesFromInput:(NSDictionary *)input {
    NSMutableDictionary *retDict = [[NSMutableDictionary alloc] init];
    [input enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isKindOfClass:[NSString class]] && [obj isKindOfClass:[NSString class]]) {
            [retDict setObject:[[[[obj stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""] stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"] stringByReplacingOccurrencesOfString:@"’" withString:@"'"] stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"] forKey:key];
        } else {
            [retDict setObject:obj forKey:key];
        }
    }];
    return retDict;
}

-(void)checkIfDeviceInstalledApp:(NSString *)deviceId {
    dispatch_async(self.asyncQueue, ^{
        NSURLSession *session = [NSURLSession sharedSession];
        NSMutableString *urlString = [[NSMutableString alloc] initWithFormat:@"%@/v2/binddevicetocookie/%@?getcookie=true", DL_API_BASE_URL, deviceId];
        [[session dataTaskWithURL:[NSURL URLWithString:urlString]
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    // handle response
                    if (error == nil)
                    {
                        NSError *convError;
                        id jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&convError];
                        if (![[jsonData objectForKey:@"cookie_id"] isEqualToString:@""]) {
                            [DLPreferenceHelper setFlagIfInstalledApp:[jsonData objectForKey:@"cookie_id"]];
                        }
                    }
                }
        ] resume];
    });
}

- (void)callClose {
    [CallClose setpost:[DeepShareImpl getcurrInstance]];
}

- (void)initSession {
    [self initSessionAndRegisterDeepLinkHandler:nil];
}

- (void)initUserSessionWithCallbackInternal:(callbackWithParams)callback {
    [self checkIfDeviceInstalledApp:[DLSystemObserver getUniqueId]];
    
    [self checkIfDeviceInstalledApp:[DLSystemObserver getUniqueId]];
    
    if (![self.requestQueue containsInstallOrOpen]) {
        [self initializeSession: callback];
    } else {
        dispatch_async(self.asyncQueue, ^{
            [self processNextQueueItem];
        });
    }
}

- (BOOL)hasAppKey {
    return ![[DLPreferenceHelper getAppKey] isEqualToString:NO_STRING_VALUE];
}

- (void)initSessionAndRegisterDeepLinkHandler:(callbackWithParams)callback {
    [self initUserSessionWithCallbackInternal:callback];
}

- (void)applicationDidBecomeActive {
    dispatch_async(self.asyncQueue, ^{
        if (![DLPreferenceHelper getInstall]) {
            [self registerInstallOrOpen:REQ_TAG_REGISTER_INSTALL withcallback:self.sessionparamLoadCallback];
        } else {
            [self registerInstallOrOpen:REQ_TAG_REGISTER_OPEN withcallback:self.sessionparamLoadCallback];
        }
    });
}

- (void)registerInstallOrOpen:(NSString *)tag withcallback: (callbackWithParams)callback {
    if ([DLSystemObserver getOSVersion].integerValue >= 9) {
        [[DLStrongMatchHelper strongMatchHelper] createStrongMatchWithDeviceId:[DLSystemObserver getUniqueId] tag:tag withcallback:callback];
        if ([tag isEqualToString:REQ_TAG_REGISTER_OPEN]) {
            [self sendInstallOrOpenReq:tag withcallback:callback];
        }
    } else {
        // code below will only run when the ios version is ios8 and before
        [self sendInstallOrOpenReq:tag withcallback:callback];
    }
}

-(void)sendInstallOrOpenReq:(NSString *)tag withcallback: (callbackWithParams)callback {
    if (![self.requestQueue containsInstallOrOpen]) {
        self.isInit = true;
        if([tag isEqualToString:REQ_TAG_REGISTER_INSTALL]) {
            registerInstall *req = [[registerInstall alloc] initWithTag:tag];
            [req setcallback: callback];
            [self insertRequestAtFront:req];
        } else {
            registerOpen *req = [[registerOpen alloc] initWithTag:tag];
            [req setcallback: callback];
            [self insertRequestAtFront:req];
        }
    } else {
        [self.requestQueue moveInstallOrOpen:tag ToFront:self.networkCount];
    }
    
    dispatch_async(self.asyncQueue, ^{
        [self processNextQueueItem];
    });
}

-(void)sendAttributeReqWithcallback:(NSDictionary *)tagToValue andCallback:(callbackWithError)callback {
    if (tagToValue == nil) {
        NSDictionary *errorDict;
        errorDict = [DSError getUserInfoDictForDomain:DSArgumentEmptyError];
        callback([NSError errorWithDomain:DSErrorDomain code:DSArgumentEmptyError userInfo:errorDict]);
    }
    
    bool has_non_zero = false;
    for (NSString *key in tagToValue) {
        if (tagToValue[key] != 0) {
            has_non_zero = true;
        }
    }
    if (has_non_zero) {
        NSMutableArray *args = [[NSMutableArray alloc] init];
        for (NSString *key in tagToValue) {
            if (tagToValue[key] != 0) {
                [args addObject:[[NSDictionary alloc] initWithObjects:@[key, tagToValue[key]] forKeys:@[@"event", @"count"]]];
            }
        }
        dispatch_async(self.asyncQueue, ^{
            NewvalueChange *req = [[NewvalueChange alloc] init];
            [req setcallback:callback];
            req.tag = REQ_TAG_CHANGE_VALUE;
            NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
            NSDictionary *receiver_info = [[NSDictionary alloc] initWithObjects:@[[DLSystemObserver getUniqueId]] forKeys:@[@"device_id"]];
            [post setObject:receiver_info forKey:@"receiver_info"];
            [post setObject:args forKey:@"counters"];
            req.postData = post;
            
            [self.requestQueue enqueue:req];
            
            [self processNextQueueItem];
        });
    }
}

-(void)getNewUsage:(callbackWithNewUsageFromMe)callback {
    dispatch_async(self.asyncQueue, ^{
        getNewUsage *req = [[getNewUsage alloc] initWithTag:REQ_TAG_GET_USAGE];
        [req setcallback:callback];
        [self.requestQueue enqueue:req];
        [self processNextQueueItem];
    });
}

-(void)clearNewUsage:(callbackWithError)callback {
    dispatch_async(self.asyncQueue, ^{
        clearNewUsage *req = [[clearNewUsage alloc] initWithTag:REQ_TAG_CLEAR_USAGE];
        [req setcallback:callback];
        [self.requestQueue enqueue:req];
        [self processNextQueueItem];
    });
}

-(void)initializeSession: (callbackWithParams)callback {
    if (![self hasAppKey]) {
        return;
    }
    
    if ([DLPreferenceHelper getInstall]) {
        [self registerInstallOrOpen:REQ_TAG_REGISTER_OPEN withcallback: callback];
    } else {
        [self registerInstallOrOpen:REQ_TAG_REGISTER_INSTALL withcallback: callback];
    }
}

- (void)clearTimer {
    [self.sessionTimer invalidate];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)insertRequestAtFront:(DLServerRequest *)req {
    if (self.networkCount == 0) {
        [self.requestQueue insert:req at:0];
    } else {
        [self.requestQueue insert:req at:1];
    }
}

- (void)processNextQueueItem {
    dispatch_semaphore_wait(self.processing_sema, DISPATCH_TIME_FOREVER);
    
    if (self.networkCount == 0 && self.requestQueue.size > 0) {
        self.networkCount = 1;
        dispatch_semaphore_signal(self.processing_sema);
        
        DLServerRequest *req = [self.requestQueue peek];
        
        if (req) {
            Servercallback callback = ^(DLServerResponse *response) {
                if (response) {
                    NSInteger status = [response.statusCode integerValue];
                    
                    BOOL retry = NO;
                    self.hasNetwork = YES;
                    if (status == 409) {
                        NSLog(@"DeepShare API Error: Duplicate DeepShare resource error.");
                        [self handleFailure:[self.requestQueue size]-1 witherror:[NSError errorWithDomain:DSErrorDomain code:status userInfo: [NSDictionary dictionaryWithObject:@[response.error] forKey:NSLocalizedDescriptionKey]]];
                    } else if (status >= 400 && status < 500) {
                        if (response.data && [response.data objectForKey:ERROR]) {
                            NSLog(@"DeepShare API Error: %@", [[response.data objectForKey:ERROR] objectForKey:MESSAGE]);
                        }
                        [self handleFailure:[self.requestQueue size]-1 witherror:[NSError errorWithDomain:DSErrorDomain code:status userInfo: [NSDictionary dictionaryWithObject:@[response.error] forKey:NSLocalizedDescriptionKey]]];
                        [self.requestQueue dequeue];
                    } else if (status != 200) {
                        retry = YES;
                        NSLog(@"DeepShare API Error: Http status code= %ld", (long)status);
                        dispatch_async(self.asyncQueue, ^{
                            [self retryLastRequest];
                        });
                    } else {
                        [req processResponse:response];
                    }
                    if (!retry && self.hasNetwork) {
                        [self.requestQueue dequeue];
                        
                        dispatch_async(self.asyncQueue, ^{
                            self.networkCount = 0;
                            [self processNextQueueItem];
                        });
                    } else {
                        self.networkCount = 0;
                    }
                }
            };
            
            if (![req.tag isEqualToString:REQ_TAG_REGISTER_CLOSE]) {
                [self clearTimer];
            }
            
            if ([req sendRequest:self.bServerInterface withcallback:callback]) {
                [DLPreferenceHelper log:FILE_NAME line:LINE_NUM message:[req message]];
            } else {
                self.networkCount = 0;
                NSDictionary *errorDict;
                errorDict = [DSError getUserInfoDictForDomain:DSInitError];
                [self handleFailure:[self.requestQueue size]-1 witherror:[NSError errorWithDomain:DSErrorDomain code:DSInitError userInfo:errorDict]];
                [self initSession];
            }
        }
    } else {
        dispatch_semaphore_signal(self.processing_sema);
    }
    
}

- (void)handleFailure:(unsigned int)index witherror: (NSError *) error{
    DLServerRequest *req;
    if (index >= [self.requestQueue size]) {
        req = [self.requestQueue peekAt:[self.requestQueue size]-1];
    } else {
        req = [self.requestQueue peekAt:index];
    }
    
    if (req) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [req processResponsewithError:error];
        });
    }
}

- (void)retryLastRequest {
    self.retryCount = self.retryCount + 1;
    if (self.retryCount > [DLPreferenceHelper getRetryCount]) {
        NSDictionary *errorDict;
        errorDict = [DSError getUserInfoDictForDomain:DSNetError];
        [self handleFailure:0 witherror:[NSError errorWithDomain:DSErrorDomain code:DSNetError userInfo:errorDict]];
        [self.requestQueue dequeue];
        self.retryCount = 0;
    } else {
        [NSThread sleepForTimeInterval:[DLPreferenceHelper getRetryInterval]];
    }
    [self processNextQueueItem];
}

@end
