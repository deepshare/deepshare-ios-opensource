//
//  DLTime.m
//  DeepShareSample
//
//  Created by Hibbert on 15/11/16.
//  Copyright © 2015年 johney.song. All rights reserved.
//

#import "DLTime.h"

@implementation DLTime

static DLTime *current;

+(void)addtimestamp:(NSString *)opration withtime:(double)time {
    if (!current) {
        current = [[DLTime alloc] init];
        current.inappdata = [[NSArray alloc] init];
        current.generateURL = [[NSArray alloc] init];
        current.attributeValue = [[NSArray alloc] init];
    }
    if ([opration isEqualToString:@"inappdata"]) {
        current.inappdata = [current.inappdata arrayByAddingObject:[NSNumber numberWithDouble:time * 1000]];
    } else if ([opration isEqualToString:@"url"]) {
        current.generateURL = [current.generateURL arrayByAddingObject:[NSNumber numberWithDouble:time * 1000]];
    } else if ([opration isEqualToString:@"attribute"]) {
        current.attributeValue = [current.attributeValue arrayByAddingObject:[NSNumber numberWithDouble:time * 1000]];
    }
}

+(NSDictionary *)gettimestamp {
    if (current) {
        return [[NSDictionary alloc] initWithObjects:@[current.inappdata, current.generateURL, current.attributeValue] forKeys:@[@"inappdata", @"genurl", @"attribute"]];
    } else {
        return [[NSDictionary alloc] initWithObjects:@[[[NSArray alloc] init], [[NSArray alloc] init], [[NSArray alloc] init]] forKeys:@[@"inappdata", @"genurl", @"attribute"]];
    }
}

@end