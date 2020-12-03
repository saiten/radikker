//
//  NADNativeLogger.h
//  NendAd
//
//  Copyright © 2015年 F@N Communications, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NADNativeLogLevel) {
    NADNativeLogLevelDebug = 1,
    NADNativeLogLevelInfo = 2,
    NADNativeLogLevelWarn = 3,
    NADNativeLogLevelError = 4,
    NADNativeLogLevelNone = INT_MAX,
};

@interface NADNativeLogger : NSObject

+ (void)setLogLevel:(NADNativeLogLevel)level;

@end
