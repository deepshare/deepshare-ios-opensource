//
//  DLStrongMatchHelper.h
//  DeepShareSample
//
//  Created by 赵海 on 15/10/10.
//  Copyright © 2015年 johney.song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeepShareImpl.h"

@interface DLStrongMatchHelper : NSObject

+ (DLStrongMatchHelper *)strongMatchHelper;
- (void)createStrongMatchWithDeviceId:(NSString *)appId tag:(NSString *)tag withcallback: (callbackWithParams)callback;

@end
