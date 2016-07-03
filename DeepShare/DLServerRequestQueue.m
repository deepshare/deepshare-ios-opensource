//
//  DLServerRequestQueue.m
//  TestDeeplink
//
//  Created by johney.song on 15/2/27.
//  Copyright (c) 2015年 johney.song. All rights reserved.
//

#import "DLServerRequestQueue.h"
#import "DLServerRequest.h"
#import "DLPreferenceHelper.h"
#import "DLServerInterface.h"

#define STORAGE_KEY     @"DLServerRequestQueue"

@interface DLServerRequestQueue()

@property (nonatomic, strong) NSMutableArray *queue;
@property (nonatomic) dispatch_queue_t asyncQueue;

@end

@implementation DLServerRequestQueue

- (id)init {
    if (self = [super init]) {
        self.queue = [NSMutableArray array];
        self.asyncQueue = dispatch_queue_create("deeplink_persist_queue", NULL);
    }
    return self;
}

- (void)enqueue:(DLServerRequest *)request {
    @synchronized(self.queue) {
        if (request) {
            [self.queue addObject:request];
        }
    }
}

- (void)insert:(DLServerRequest *)request at:(unsigned int)index {
    @synchronized(self.queue) {
        if (index > self.queue.count) {
            [DLPreferenceHelper log:FILE_NAME line:LINE_NUM message:@"Invalid queue operation: index out of bound!"];
            return;
        }
        
        if (request) {
            [self.queue insertObject:request atIndex:index];
        }
    }
}

- (DLServerRequest *)dequeue {
    DLServerRequest *request = nil;
    
    @synchronized(self.queue) {
        if (self.queue.count > 0) {
            request = [self.queue objectAtIndex:0];
            [self.queue removeObjectAtIndex:0];
        }
    }
    
    return request;
}

- (DLServerRequest *)peek {
    return [self peekAt:0];
}

- (DLServerRequest *)peekAt:(unsigned int)index {
    if (index >= self.queue.count) {
        [DLPreferenceHelper log:FILE_NAME line:LINE_NUM message:@"Invalid queue operation: index out of bound!"];
        return nil;
    }
    
    DLServerRequest *request = nil;
    request = [self.queue objectAtIndex:index];
    
    return request;
}

- (unsigned int)size {
    return (unsigned int)self.queue.count;
}

- (NSString *)description {
    return [self.queue description];
}

- (BOOL)containsInstallOrOpen {
    for (int i = 0; i < self.queue.count; i++) {
        DLServerRequest *req = [self.queue objectAtIndex:i];
        if (req && ([req.tag isEqualToString:REQ_TAG_REGISTER_INSTALL] || [req.tag isEqualToString:REQ_TAG_REGISTER_OPEN])) {
            return YES;
        }
    }
    return NO;
}

- (DLServerRequest *)removeAt:(unsigned int)index {
    DLServerRequest *request = nil;
    @synchronized(self.queue) {
        if (index >= self.queue.count) {
            [DLPreferenceHelper log:FILE_NAME line:LINE_NUM message:@"Invalid queue operation: index out of bound!"];
            return nil;
        }
        
        request = [self.queue objectAtIndex:index];
        [self.queue removeObjectAtIndex:index];
    }
    
    return request;
}

- (BOOL)containsClose {
    for (int i = 0; i < self.queue.count; i++) {
        DLServerRequest *req = [self.queue objectAtIndex:i];
        if ([req.tag isEqualToString:REQ_TAG_REGISTER_CLOSE]) {
            return YES;
        }
    }
    return NO;
}

- (void)moveInstallOrOpen:(NSString *)tag ToFront:(NSInteger)networkCount {
    for (int i = 0; i < self.queue.count; i++) {
        DLServerRequest *req = [self.queue objectAtIndex:i];
        if ([req.tag isEqualToString:REQ_TAG_REGISTER_INSTALL] || [req.tag isEqualToString:REQ_TAG_REGISTER_OPEN]) {
            [self removeAt:i];
            break;
        }
    }
    
    DLServerRequest *req = [[DLServerRequest alloc] initWithTag:tag];
    if (networkCount == 0) {
        [self insert:req at:0];
    } else {
        [self insert:req at:1];
    }
}

+ (id)getInstance {
    static DLServerRequestQueue *sharedQueue = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedQueue = [[DLServerRequestQueue alloc] init];
        sharedQueue.queue = [[NSMutableArray alloc] init];
    });
    
    return sharedQueue;
}

@end
