//
//  DLError.m
//  TestDeeplink
//
//  Created by johney.song on 15/3/3.
//  Copyright (c) 2015年 johney.song. All rights reserved.
//

#import "DSError.h"

NSString *const DSErrorDomain = @"pango.link";

@implementation DSError

+ (NSDictionary *)getUserInfoDictForDomain:(NSInteger)code {
    switch (code) {
        case DSInitError:
            return [NSDictionary dictionaryWithObject:@[@"Failed to initialize - are you using the right API key?"] forKey:NSLocalizedDescriptionKey];
        case DSNotInitError:
            return [NSDictionary dictionaryWithObject:@[@"You can't make a DeepShare call without first initializing the session. Did you add the initWithAppKey call to the AppDelegate?"] forKey:NSLocalizedDescriptionKey];
        case DSArgumentEmptyError:
            return [NSDictionary dictionaryWithObject:@[@"Argument is Empty - check your input"] forKey:NSLocalizedDescriptionKey];
        case DSNetError:
            return [NSDictionary dictionaryWithObject:@[@"Internet Error - check network connectivity?"] forKey:NSLocalizedDescriptionKey];
        case DSInitFailedError:
            return [NSDictionary dictionaryWithObject:@[@"Failed to initialize - please call init again"] forKey:NSLocalizedDescriptionKey];
        case DSNotReferenceSafariService:
            return [NSDictionary dictionaryWithObject:@[@"Failed to find SafariService.framework - please add it"] forKey:NSLocalizedDescriptionKey];
    }
    return [NSDictionary dictionaryWithObject:@[@"Trouble reaching server. Please try again in a few minutes"] forKey:NSLocalizedDescriptionKey];
}

@end
