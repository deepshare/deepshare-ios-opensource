//
//  getNewUsage.m
//  DeepShareSample
//
//  Created by 赵海 on 15/12/22.
//  Copyright © 2015年 johney.song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "getNewUsage.h"
#import "DLTime.h"
#import "DLServerInterface.h"

@interface getNewUsage()

@property (strong, nonatomic) callbackWithNewUsageFromMe callback;
@property (nonatomic) double starttime;

@end

@implementation getNewUsage

- (void) setcallback: (callbackWithNewUsageFromMe) callback {
    self.callback = callback;
}

- (NSString *) typeofRequest {
    return @"dsusages";
}

- (NSString *) message {
    return @"calling get new usage";
}

- (void) processResponsewithError: (NSError *) error {
    self.callback(0, 0, error);
    double time = CACurrentMediaTime() - self.starttime;
    [DLTime addtimestamp:[self typeofRequest] withtime:time];
}

- (void) processResponse: (DLServerResponse *) response {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.callback) self.callback([[response.data objectForKey:@"new_install"] intValue], [[response.data objectForKey:@"new_open"] intValue], nil);
        double time = CACurrentMediaTime() - self.starttime;
        [DLTime addtimestamp:@"getusage" withtime:time];
    });
}

- (BOOL) sendRequest: (DLServerInterface *) serverInterface withcallback: (Servercallback) callback {
    self.starttime = CACurrentMediaTime();
    NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
    
    [serverInterface getRequestAsync:post url:[DLPreferenceHelper getAPIURL:[NSString stringWithFormat:@"%@/%@/%@", [self typeofRequest], [DLPreferenceHelper getAppKey], [DLPreferenceHelper getUniqueID]]] andTag:self.tag withcallback: callback];
    return true;
}

@end
