//
//  DLServerInterface.h
//  TestDeeplink
//
//  Created by johney.song on 15/2/26.
//  Copyright (c) 2015年 johney.song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLServerResponse.h"

static NSString *REQ_TAG_REGISTER_INSTALL = @"t_register_install";
static NSString *REQ_TAG_REGISTER_OPEN = @"t_register_open";
static NSString *REQ_TAG_REGISTER_CLOSE = @"t_register_close";
static NSString *REQ_TAG_GET_USAGE = @"t_get_usage";
static NSString *REQ_TAG_CLEAR_USAGE = @"t_clear_usage";
static NSString *REQ_TAG_GET_CUSTOM_URL = @"t_get_custom_url";
static NSString *REQ_TAG_CHANGE_VALUE = @"t_change_value";

@protocol DLServerInterfaceDelegate <NSObject>

@optional
- (void)serverCallback:(DLServerResponse *)returnedData;

@end

typedef void (^Servercallback) (DLServerResponse *response);

static NSString *kpServerIdentNone = @"no_value";
static NSString *REQ_TAG_DEBUG_CONNECT = @"t_debug_connect";
static NSString *REQ_TAG_DEBUG_LOG = @"t_debug_log";
static NSString *REQ_TAG_DEBUG_SCREEN = @"t_debug_screen";
static NSString *REQ_TAG_DEBUG_DISCONNECT = @"t_debug_disconnect";

@interface DLServerInterface : NSObject

@property (nonatomic, strong) id <DLServerInterfaceDelegate> delegate;

+ (NSString *)encodePostToUniversalString:(NSDictionary *)params;
- (void)postRequestAsync:(NSDictionary *)post url:(NSString *)url andTag:(NSString *)requestTag withcallback: (Servercallback)callback;
- (void)getRequestAsync:(NSDictionary *)post url:(NSString *)url andTag:(NSString *)requestTag withcallback: (Servercallback)callback;
- (void)deleteRequestAsync:(NSDictionary *)post url:(NSString *)url andTag:(NSString *)requestTag withcallback: (Servercallback)callback;
- (void)generateRequestAsync:(NSDictionary *)post url:(NSString *)url andTag:(NSString *)requestTag log:(BOOL)log method:(NSString *)method withcallback: (Servercallback)callback;

@end
