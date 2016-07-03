//
//  clearNewUsage.h
//  DeepShareSample
//
//  Created by 赵海 on 15/12/23.
//  Copyright © 2015年 johney.song. All rights reserved.
//

#import "DLServerRequest.h"
#import "DeepShareImpl.h"

@interface clearNewUsage : DLServerRequest

- (void) setcallback: (callbackWithError) callback;
- (NSString *) typeofRequest;
- (NSString *) message;
- (void) processResponsewithError: (NSError *) error;
- (void) processResponse: (DLServerResponse *) response;
- (BOOL) sendRequest: (DLServerInterface *) serverInterface withcallback: (Servercallback) callback;

@end
