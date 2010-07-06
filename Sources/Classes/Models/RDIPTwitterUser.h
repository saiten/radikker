//
//  RDIPTwitterUser.h
//  radikker
//
//  Created by saiten  on 10/04/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RDIPTwitterUser : NSObject {
	UInt64 userId;
	NSString *name;
	NSString *screenName;
	NSString *location;
	NSString *description;
	NSString *url;
	NSString *imageUrl;

	BOOL protected;
	BOOL following;

	UInt32 statusesCount;
	UInt32 followersCount;
	UInt32 friendsCount;

	NSDate *created;
}

@property(nonatomic, readonly) UInt64 userId;
@property(nonatomic, readonly) NSString *name, *screenName, *location, *description, *url, *imageUrl;
@property(nonatomic, readonly) UInt32 statusesCount, followersCount, friendsCount;
@property(nonatomic, readonly) BOOL protected, following;
@property(nonatomic, readonly) NSDate *created;

+ (RDIPTwitterUser*)userWithDictionary:(NSDictionary*)dic;

@end
