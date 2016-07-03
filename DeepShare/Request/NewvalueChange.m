//
//  NewvalueChange.m
//  DeepShareSample
//
//  Created by Hibbert on 15/10/13.
//  Copyright © 2015年 johney.song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewvalueChange.h"
#import "DLPreferenceHelper.h"
#import "DLServerInterface.h"
#import "DLTime.h"

@interface NewvalueChange()

@property (strong, nonatomic) callbackWithError callback;
@property (nonatomic) double starttime;

@end

@implementation NewvalueChange

- (void) setcallback: (callbackWithError) callback {
    self.callback = callback;
}

- (NSString *) typeofRequest {
    return @"counters";
}

- (NSString *) message {
    return @"calling change value";
}

- (void) processResponsewithError: (NSError *) error {
    self.callback(error);
    double time = CACurrentMediaTime() - self.starttime;
    [DLTime addtimestamp:@"attribute" withtime:time];
}

- (void) processResponse: (DLServerResponse *) response {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.callback) self.callback(nil);
        double time = CACurrentMediaTime() - self.starttime;
        [DLTime addtimestamp:@"attribute" withtime:time];
    });
}

- (BOOL) sendRequest: (DLServerInterface *) serverInterface withcallback: (Servercallback) callback {
    self.starttime = CACurrentMediaTime();
    [serverInterface postRequestAsync:self.postData url:[DLPreferenceHelper getAPIURL:[NSString stringWithFormat:@"%@/%@", [self typeofRequest], [DLPreferenceHelper getAppKey]]] andTag:self.tag withcallback: callback];
    return true;
}

@end