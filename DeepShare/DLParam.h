//
//  DLParam.h
//  DeepShareSample
//
//  Created by Hibbert on 15/10/15.
//  Copyright © 2015年 johney.song. All rights reserved.
//

typedef enum {
    DeepLinkTypeUnlimitedUse = 0,
    DeepLinkTypeOneTimeUse = 1
} DeepLinkType;

static NSString *APP_ID = @"app_id";
static NSString *IDENTITY = @"identity";
static NSString *IDENTITY_ID = @"identity_id";
static NSString *SESSION_ID = @"session_id";
static NSString *TAGS = @"tags";
static NSString *CHANNEL = @"channel";
static NSString *FEATURE = @"feature";
static NSString *STAGE = @"stage";
static NSString *ALIAS = @"alias";
static NSString *DATA = @"data";
static NSString *LINK_TYPE = @"type";
static NSString *MESSAGE = @"message";
static NSString *ERROR = @"error";
static NSString *DEVICE_FINGERPRINT_ID = @"device_fingerprint_id";
static NSString *LINK = @"link";
static NSString *LINK_CLICK_ID = @"link_click_id";
static NSString *URL = @"url";
static NSString *TAGGED_VALUE = @"tag_values";
