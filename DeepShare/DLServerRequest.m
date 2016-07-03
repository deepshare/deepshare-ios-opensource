//
//  DLServerRequest.m
//  TestDeeplink
//
//  Created by johney.song on 15/2/27.
//  Copyright (c) 2015年 johney.song. All rights reserved.
//

#import "DLServerRequest.h"
#import "DLPreferenceHelper.h"

#define TAG         @"TAG"
#define DATA        @"POSTDATA"

@implementation DLServerRequest

- (NSString *) typeofRequest {
    return @"";
}

- (NSString *) message {
    return @"";
}

- (void) processResponsewithError: (NSError *) error {
    //nothing here
}

- (void) processResponse: (DLServerResponse *) response {
    //nothing here
}

- (BOOL) sendRequest: (DLServerInterface *) serverInterface withcallback: (Servercallback) callback {
    return false;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    if (self.tag) {
        [coder encodeObject:self.tag forKey:TAG];
    }
    if (self.postData) {
        [coder encodeObject:self.postData forKey:DATA];
    }
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.tag = [coder decodeObjectForKey:TAG];
        self.postData = [coder decodeObjectForKey:DATA];
    }
    return self;
}


- (id)initWithTag:(NSString *)tag {
    return [self initWithTag:tag andData:nil];
}

- (id)initWithTag:(NSString *)tag andData:(NSDictionary *)postData {
    if (!tag) {
        
        [DLPreferenceHelper log:FILE_NAME line:LINE_NUM message:@"Invalid: server request missing tag!"];
        return nil;
    }
    
    if (self = [super init]) {
        self.tag = tag;
        self.postData = postData;
    }
    
    return self;
}

@end
