//
//  DLServerInterface.m
//  TestDeeplink
//
//  Created by johney.song on 15/2/26.
//  Copyright (c) 2015年 johney.song. All rights reserved.
//

#import "DLServerInterface.h"
#import "DLServerResponse.h"
#import "DLPreferenceHelper.h"

@implementation DLServerInterface

+ (NSString *)encodePostToUniversalString:(NSDictionary *)params {
    return [DLServerInterface encodePostToUniversalString:params needSource:NO];
}

+ (NSString *)encodePostToUniversalString:(NSDictionary *)params needSource:(BOOL)source {
    NSMutableString *encodedParams = [[NSMutableString alloc] initWithString:@"{ "];
    for (NSString *key in params) {
        NSString *value = nil;
        BOOL string = YES;
        if ([[params objectForKey:key] isKindOfClass:[NSString class]]) {
            value = [params objectForKey:key];
        } else if ([[params objectForKey:key] isKindOfClass:[NSDictionary class]]) {
            value = [DLServerInterface encodePostToUniversalString:[params objectForKey:key]];
        } else if ([[params objectForKey:key] isKindOfClass:[NSNumber class]]) {
            value = [[params objectForKey:key] stringValue];
            string = NO;
        }
        [encodedParams appendString:@"\""];
        [encodedParams appendString:key];
        if (string) [encodedParams appendString:@"\":\""];
        else [encodedParams appendString:@"\":"];
        [encodedParams appendString:value];
        if (string) [encodedParams appendString:@"\","];
        else [encodedParams appendString:@","];
    }
    
    if (source) {
        [encodedParams appendString:@"\"source\":\"ios\" }"];
    } else {
        [encodedParams deleteCharactersInRange:NSMakeRange([encodedParams length]-1, 1)];
        [encodedParams appendString:@" }"];
    }
    
    [DLPreferenceHelper log:FILE_NAME line:LINE_NUM message:@"encoded params : %@", encodedParams];
    
    return encodedParams;
}

- (void)genericHTTPRequest:(NSMutableURLRequest *)request withTag:(NSString *)requestTag withcallback: (Servercallback) callback {
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request.copy completionHandler:^(NSData * _Nullable POSTReply, NSURLResponse * _Nullable response, NSError * _Nullable error) {
#else
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *POSTReply, NSError *error) {
#endif
        DLServerResponse *serverResponse;
        if (!error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSNumber *statusCode = [NSNumber numberWithLong:[httpResponse statusCode]];
            serverResponse = [[DLServerResponse alloc] initWithTag:requestTag andStatusCode:statusCode];
            if (POSTReply != nil) {
                NSString *string = [[NSString alloc] initWithData:POSTReply encoding:NSUTF8StringEncoding];
                serverResponse.error = string;
                NSError *convError;
                id jsonData = [NSJSONSerialization JSONObjectWithData:POSTReply options:NSJSONReadingMutableContainers error:&convError];
                serverResponse.data = jsonData;
            }
        } else {
            serverResponse = [[DLServerResponse alloc] initWithTag:requestTag andStatusCode:[NSNumber numberWithInteger:error.code]];
            serverResponse.data = error.userInfo;
        }
        if ([DLPreferenceHelper isDebug]  // for efficiency short-circuit purpose
            && ![requestTag isEqualToString:REQ_TAG_DEBUG_LOG]
            && ![requestTag isEqualToString:REQ_TAG_DEBUG_CONNECT]
            && [requestTag isEqualToString:REQ_TAG_DEBUG_DISCONNECT]
            && [requestTag isEqualToString:REQ_TAG_DEBUG_SCREEN])
        {
            [DLPreferenceHelper log:FILE_NAME line:LINE_NUM message:@"returned = %@", [serverResponse description]];
        }
        
        if (callback) callback(serverResponse);
        else if (self.delegate) [self.delegate serverCallback:serverResponse];
    }];
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
    [task resume];
#endif
}


+ (NSData *)encodePostParams:(NSDictionary *)params {
    NSError *writeError = nil;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&writeError];
    return postData;
}

// make a generalized post request
- (void)postRequestAsync:(NSDictionary *)post url:(NSString *)url andTag:(NSString *)requestTag withcallback: (Servercallback) callback {
    [self generateRequestAsync:post url:url andTag:requestTag log:YES method:@"POST" withcallback: callback];
}
                                  
// make a generalized get request
- (void)getRequestAsync:(NSDictionary *)post url:(NSString *)url andTag:(NSString *)requestTag withcallback: (Servercallback) callback {
    [self generateWithoutBodyRequestAsync:post url:url andTag:requestTag log:YES method:@"GET" withcallback: callback];
}
                                  
// make a generalized get request
- (void)deleteRequestAsync:(NSDictionary *)post url:(NSString *)url andTag:(NSString *)requestTag withcallback: (Servercallback) callback {
    [self generateWithoutBodyRequestAsync:post url:url andTag:requestTag log:YES method:@"DELETE" withcallback: callback];
}

- (void)generateRequestAsync:(NSDictionary *)post url:(NSString *)url andTag:(NSString *)requestTag log:(BOOL)log method:(NSString *)method withcallback:(Servercallback)callback {
    NSData *postData = [DLServerInterface encodePostParams:post];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    if (log) {
        [DLPreferenceHelper log:FILE_NAME line:LINE_NUM message:@"using url = %@", url];
        [DLPreferenceHelper log:FILE_NAME line:LINE_NUM message:@"body = %@", [post description]];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setTimeoutInterval:[DLPreferenceHelper getTimeout]];
    [request setHTTPMethod:method];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setHTTPBody:postData];
    
    [self genericHTTPRequest:request withTag:requestTag withcallback: callback];
}
                                  
- (void)generateWithoutBodyRequestAsync:(NSDictionary *)post url:(NSString *)url andTag:(NSString *)requestTag log:(BOOL)log method:(NSString *)method withcallback:(Servercallback)callback {
                                      
    if (log) {
        [DLPreferenceHelper log:FILE_NAME line:LINE_NUM message:@"using url = %@", url];
        [DLPreferenceHelper log:FILE_NAME line:LINE_NUM message:@"body = %@", [post description]];
    }
                                      
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setTimeoutInterval:[DLPreferenceHelper getTimeout]];
    [request setHTTPMethod:method];
                                      
    [self genericHTTPRequest:request withTag:requestTag withcallback: callback];
}
@end
