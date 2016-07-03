//
//  CallClose.m
//  DeepShareSample
//
//  Created by Hibbert on 15/10/14.
//  Copyright © 2015年 johney.song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CallClose.h"
#import "DLPreferenceHelper.h"
#import "DLServerInterface.h"
#import "DLTime.h"

@implementation CallClose

+ (void) setpost: (DeepShareImpl *)deepshare {
    if (!deepshare.hasNetwork) {
        // if there's no network connectivity, purge the old install/open
        DLServerRequest *req = [deepshare.requestQueue peek];
        if (req && ([req.tag isEqualToString:REQ_TAG_REGISTER_INSTALL] || [req.tag isEqualToString:REQ_TAG_REGISTER_OPEN])) {
            [deepshare.requestQueue dequeue];
        }
    } else {
        if (![deepshare.requestQueue containsClose]) {
            CallClose *req = [[CallClose alloc] initWithTag:REQ_TAG_REGISTER_CLOSE];
            NSMutableDictionary *post = [[NSMutableDictionary alloc] initWithObjects:@[[NSString stringWithFormat:@"ios%@", SDK_VERSION]] forKeys:@[@"sdk"]];
            req.postData = post;
            [deepshare.requestQueue enqueue:req];
        }
        
        dispatch_async(deepshare.asyncQueue, ^{
            [deepshare processNextQueueItem];
        });
    }
}

- (NSString *) typeofRequest {
    return @"dsactions";
}

- (NSString *) message {
    return @"calling close";
}

- (BOOL) sendRequest: (DLServerInterface *) serverInterface withcallback: (Servercallback) callback {
    NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
    NSDictionary *receiver_info = [[NSDictionary alloc] initWithObjects:@[[DLSystemObserver getUniqueId]] forKeys:@[@"unique_id"]];
    [post setObject:receiver_info forKey:@"receiver_info"];
    [post setObject:@"app/close" forKey:@"action"];
    if ([DLTime gettimestamp]) {
        NSDictionary *kvs = [[NSDictionary alloc] initWithObjects:@[[DLTime gettimestamp]] forKeys:@[@"lapse"]];
        [post setObject:kvs forKey:@"kvs"];
    }
    [serverInterface postRequestAsync:post url:[DLPreferenceHelper getAPIURL:[self typeofRequest]] andTag:self.tag withcallback:callback];
    return true;
}

@end