//
//  NewvalueChange.h
//  DeepShareSample
//
//  Created by Hibbert on 15/10/13.
//  Copyright © 2015年 johney.song. All rights reserved.
//

#import "DLServerRequest.h"
#import "DeepShareImpl.h"

@interface NewvalueChange : DLServerRequest

- (void) setcallback: (callbackWithError) callback;
- (NSString *) typeofRequest;
- (NSString *) message;
- (void) processResponsewithError: (NSError *) error;
- (void) processResponse: (DLServerResponse *) response;
- (BOOL) sendRequest: (DLServerInterface *) serverInterface withcallback: (Servercallback) callback;

@end
