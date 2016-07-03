//
//  DLServerRequest.h
//  TestDeeplink
//
//  Created by johney.song on 15/2/27.
//  Copyright (c) 2015年 johney.song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLServerResponse.h"
#import "DLServerInterface.h"
#import "DLParam.h"

@interface DLServerRequest : NSObject

@property (strong, nonatomic) NSString *tag;
@property (strong, nonatomic) NSDictionary *postData;

- (id)initWithTag:(NSString *)tag;

- (NSString *) typeofRequest;
- (NSString *) message;
- (void) processResponsewithError: (NSError *) error;
- (void) processResponse: (DLServerResponse *) response;
- (BOOL) sendRequest: (DLServerInterface *) serverInterface withcallback: (Servercallback) callback;
@end
