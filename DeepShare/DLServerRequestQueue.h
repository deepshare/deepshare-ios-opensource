//
//  DLServerRequestQueue.h
//  TestDeeplink
//
//  Created by johney.song on 15/2/27.
//  Copyright (c) 2015年 johney.song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLServerRequest.h"

@interface DLServerRequestQueue : NSObject

@property (nonatomic, readonly) unsigned int size;

+ (id)getInstance;

- (void)enqueue:(DLServerRequest *)request;
- (DLServerRequest *)dequeue;
- (DLServerRequest *)peek;
- (DLServerRequest *)peekAt:(unsigned int)index;
- (void)insert:(DLServerRequest *)request at:(unsigned int)index;
- (DLServerRequest *)removeAt:(unsigned int)index;

- (BOOL)containsInstallOrOpen;
- (BOOL)containsClose;
- (void)moveInstallOrOpen:(NSString *)tag ToFront:(NSInteger)networkCount;


@end
