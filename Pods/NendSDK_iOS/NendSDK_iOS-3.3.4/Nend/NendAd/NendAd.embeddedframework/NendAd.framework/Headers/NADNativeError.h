//
//  NADNativeError.h
//  NendAd
//
//  Copyright (c) 2015年 F@N Communications, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kNADNativeErrorDomain;

extern NSInteger const kNADNativeErrorCodeExcessiveAdCalls;
extern NSInteger const kNADNativeErrorCodeFailedToRequest;
extern NSInteger const kNADNativeErrorCodeInvalidResponseType;

@interface NADNativeError : NSError

@end
