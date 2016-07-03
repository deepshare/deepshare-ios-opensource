//
//  DLServerResponse.m
//  TestDeeplink
//
//  Created by johney.song on 15/2/26.
//  Copyright (c) 2015年 johney.song. All rights reserved.
//

#import "DLServerResponse.h"

@implementation DLServerResponse

- (id)initWithTag:(NSString *)tag andStatusCode:(NSNumber *)code {
    if (!tag || !code) {
        return nil;
    }
    
    if (self = [super init]) {
        self.tag = tag;
        self.statusCode = code;
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Tag: %@; Status: %@; Data: %@", self.tag, self.statusCode, self.data];
}

@end
