//
//  RDIPTwitterStatus.h
//  radikker
//
//  Created by saiten  on 10/04/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDIPTwitterUser.h"

@interface RDIPTwitterStatus : NSObject {
	RDIPTwitterUser *user;
	UInt64 statusId;
	NSDate *created;
	NSString *text;
	NSString *source;
	BOOL favorite;	
}

@property(nonatomic, readonly) RDIPTwitterUser *user;
@property(nonatomic, readonly) UInt64 statusId;
@property(nonatomic, readonly) NSDate *created;
@property(nonatomic, readonly) NSString *text, *source;
@property(nonatomic, readonly) BOOL favorite;

+ (RDIPTwitterStatus*)statusWithDictionary:(NSDictionary*)dic;
- (NSString*)textByAppendLinks;
- (NSString*)stringCreatedSinceNow;

@end
