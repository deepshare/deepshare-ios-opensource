//
//  CallClose.h
//  DeepShareSample
//
//  Created by Hibbert on 15/10/14.
//  Copyright © 2015年 johney.song. All rights reserved.
//

#import "DLServerRequest.h"
#import "DeepShareImpl.h"

@interface CallClose : DLServerRequest

+ (void) setpost: (DeepShareImpl *)deepshare;
- (NSString *) typeofRequest;
- (NSString *) message;
- (BOOL) sendRequest: (DLServerInterface *) serverInterface withcallback: (Servercallback) callback;

@end
