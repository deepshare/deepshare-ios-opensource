//
//  DLTime.h
//  DeepShareSample
//
//  Created by Hibbert on 15/11/16.
//  Copyright © 2015年 johney.song. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLTime : NSObject

@property (strong, nonatomic) NSArray *inappdata;
@property (strong, nonatomic) NSArray *generateURL;
@property (strong, nonatomic) NSArray *attributeValue;

+(void)addtimestamp:(NSString *)opration withtime:(double)time;
+(NSDictionary *)gettimestamp;

@end