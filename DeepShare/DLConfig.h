//
//  DLConfig.h
//  TestDeeplink
//
//  Created by johney.song on 15/2/28.
//  Copyright (c) 2015年 johney.song. All rights reserved.
//

#ifndef Deeplink_SDK_Config_h
#define Deeplink_SDK_Config_h

#define SDK_VERSION             @"2.1.3"
#define DOMAIN_UNIVERSAL_LINK   @"fds.so"
#define IDFA_DISABLE      @"IDFAdisable"

#define DL_PROD_ENV
//#define DL_STAGE_ENV
//#define DL_DEV_ENV

#ifdef DL_PROD_ENV
#define DL_API_BASE_URL        @"https://fds.so"
//#define DL_API_BASE_URL        @"http://42.159.133.35:8080"
#endif

#ifdef DL_STAGE_ENV
#define DL_API_BASE_URL        @"http://115.28.182.217:8080"
#endif

#ifdef DL_DEV_ENV
#define DL_API_BASE_URL        @"http://deepshare.chinacloudapp.cn:8080"
#endif

#define DL_API_VERSION         @"v2"

#endif

