//
//  RDIPTwitterUser.m
//  radikker
//
//  Created by saiten  on 10/04/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPTwitterUser.h"
#import "NSString+RDIPExtend.h"
#import "NSDictionary+RDIPExtend.h"
#import "NSDate+RDIPExtend.h"

@implementation RDIPTwitterUser

@synthesize userId, name, screenName, location, description, url, imageUrl, protected, following;
@synthesize statusesCount, followersCount, friendsCount, created;

- (void)setUserWithResultDic:(NSDictionary*)dic
{
	userId         = [(NSNumber*)[dic myObjectForKey:@"from_user_id"] unsignedLongLongValue];
	screenName     = [[dic stringForKey:@"from_user"] retain];
	imageUrl       = [[dic stringForKey:@"profile_image_url"] retain];
}

- (void)setUserWithUserDic:(NSDictionary*)dic
{
	userId         = [(NSNumber*)[dic myObjectForKey:@"id"] unsignedLongLongValue];
	name           = [[dic stringForKey:@"name"] retain];
	screenName     = [[dic stringForKey:@"screen_name"] retain];
	location       = [[dic stringForKey:@"location"] retain];
	description    = [[dic stringForKey:@"description"] retain];
	url            = [[dic stringForKey:@"url"] retain];
	imageUrl       = [[dic stringForKey:@"profile_image_url"] retain];
	protected      = [(NSNumber*)[dic myObjectForKey:@"protected"] boolValue];
	following      = [(NSNumber*)[dic myObjectForKey:@"following"] boolValue];
	
	statusesCount  = [(NSNumber*)[dic myObjectForKey:@"statuses_count"] unsignedIntValue];		
	followersCount = [(NSNumber*)[dic myObjectForKey:@"followers_count"] unsignedIntValue];		
	friendsCount   = [(NSNumber*)[dic myObjectForKey:@"friends_count"] unsignedIntValue];
	
	created = [[[dic myObjectForKey:@"created_at"] dateWithFormat:@"EEE MMM d HH:mm:ss Z yyyy"] retain];
}

- (id)initWithDictionary:(NSDictionary*)dic
{
	if(self = [super init]) {

		if([dic myObjectForKey:@"from_user_id"]) {
			[self setUserWithResultDic:dic];
		} else {
			[self setUserWithUserDic:dic];
		}
		
	}
	
	return self;
}

+ (RDIPTwitterUser*)userWithDictionary:(NSDictionary *)dic
{
	return [[[RDIPTwitterUser alloc] initWithDictionary:dic] autorelease];
}

- (void)dealloc
{
	[name release];
	[screenName release];
	[location release];
	[description release];
	[url release];
	[imageUrl release];
	[created release];
	
	[super dealloc];
}


@end
