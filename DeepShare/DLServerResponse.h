//
//  DLServerResponse.h
//  TestDeeplink
//
//  Created by johney.song on 15/2/26.
//  Copyright (c) 2015年 johney.song. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLServerResponse : NSObject

@property (nonatomic, strong) NSNumber *statusCode;
@property (nonatomic, strong) NSString *tag;
@property (nonatomic, strong) id data;
@property (nonatomic, strong) NSString *error;

- (id)initWithTag:(NSString *)tag andStatusCode:(NSNumber *)code;

@end
