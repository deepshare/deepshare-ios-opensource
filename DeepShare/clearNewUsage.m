//
//  clearNewUsage.m
//  DeepShareSample
//
//  Created by 赵海 on 15/12/23.
//  Copyright © 2015年 johney.song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "clearNewUsage.h"
#import "DLTime.h"
#import "DLServerInterface.h"

@interface clearNewUsage()

@property (strong, nonatomic) callbackWithError callback;
@property (nonatomic) double starttime;

@end

@implementation clearNewUsage

- (void) setcallback: (callbackWithError) callback {
    self.callback = callback;
}

- (NSString *) typeofRequest {
    return @"dsusages";
}

- (NSString *) message {
    return @"calling get new usage";
}

- (void) processResponsewithError: (NSError *) error {
    self.callback(error);
    double time = CACurrentMediaTime() - self.starttime;
    [DLTime addtimestamp:@"clearUsage" withtime:time];
}

- (void) processResponse: (DLServerResponse *) response {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.callback) self.callback(nil);
        double time = CACurrentMediaTime() - self.starttime;
        [DLTime addtimestamp:@"clearUsage" withtime:time];
    });
}

- (BOOL) sendRequest: (DLServerInterface *) serverInterface withcallback: (Servercallback) callback {
    self.starttime = CACurrentMediaTime();
    NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
    [serverInterface deleteRequestAsync:post url:[DLPreferenceHelper getAPIURL:[NSString stringWithFormat:@"%@/%@/%@", [self typeofRequest], [DLPreferenceHelper getAppKey], [DLPreferenceHelper getUniqueID]]] andTag:self.tag withcallback: callback];
    return true;
}

@end
