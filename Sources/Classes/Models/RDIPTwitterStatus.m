//
//  RDIPTwitterStatus.m
//  radikker
//
//  Created by saiten  on 10/04/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPTwitterStatus.h"
#import "RDIPTwitterUser.h"
#import "NSString+RDIPExtend.h"
#import "NSDictionary+RDIPExtend.h"
#import "NSDate+RDIPExtend.h"
#import "RegexKitLite.h"

@implementation RDIPTwitterStatus

@synthesize user, statusId, created, text, source, favorite;

- (id)initWithDictionary:(NSDictionary*)dic
{
	if(self = [super init]) {
		
		NSDictionary *userDic = nil;

		if([dic objectForKey:@"user"]) {
			userDic = [dic objectForKey:@"user"];
		} else if([dic objectForKey:@"sender"]) {
			userDic = [dic objectForKey:@"sender"];
		} else {
			userDic = dic;
		}

		user     = [[RDIPTwitterUser userWithDictionary:userDic] retain];
		statusId = [(NSNumber*)[dic objectForKey:@"id"] unsignedLongLongValue];

		text     = [[dic stringForKey:@"text"] retain];
		source   = [[dic stringForKey:@"source"] retain];
		favorite = [(NSNumber*)[dic myObjectForKey:@"favorite"] boolValue];

		created  = [[[dic myObjectForKey:@"created_at"] dateWithFormat:@"EEE MMM d HH:mm:ss Z yyyy"] retain];
		if(created == nil) {
			created  = [[[dic myObjectForKey:@"created_at"] dateWithFormat:@"EEE, d MMM yyyy HH:mm:ss Z"] retain];
		}
	}
	
	return self;
}

+ (RDIPTwitterStatus*)statusWithDictionary:(NSDictionary *)dic
{
	return [[[RDIPTwitterStatus alloc] initWithDictionary:dic] autorelease];
}

- (NSComparisonResult)compare:(RDIPTwitterStatus*)another
{
	return self.statusId < another.statusId ? NSOrderedAscending 
	                                        : self.statusId > another.statusId ? NSOrderedDescending 
																			   : NSOrderedSame;
}

- (NSComparisonResult)compareLatest:(RDIPTwitterStatus*)another
{
	NSComparisonResult ret = [self compare:another];
	return  ret == NSOrderedAscending ? NSOrderedDescending 
	                                  : ret == NSOrderedDescending ? NSOrderedAscending 
	                                                               : NSOrderedSame;
}

- (NSString*)textByAppendLinks
{
	return [[[text stringByReplacingOccurrencesOfRegex:@"https?://[-_.!~*'()a-zA-Z0-9;/?:@&=+$,%#]+" withString:@"<a href=\"$0\">$0</a>"]
				   stringByReplacingOccurrencesOfRegex:@"@([A-Za-z0-9_]+)" withString:@"<a href=\"rdip://user/$1\">$0</a>"]
			       stringByReplacingOccurrencesOfRegex:@"#([A-Za-z0-9_]+)" withString:@"<a href=\"rdip://search/%23$1\">$0</a>"];
}

- (NSString*)stringCreatedSinceNow
{
	NSString *s = nil;
	NSDate *now = [NSDate date];
	NSTimeInterval interval = [now timeIntervalSinceDate:created];
	if(interval <= 60.0)
		s = [NSString stringWithFormat:@"less than a minute ago"];
	else if(interval <= 120.0)
		s = [NSString stringWithFormat:@"1 minute ago"];
	else if(interval <= 3600.0)
		s = [NSString stringWithFormat:@"%d minutes ago", (int)interval / 60];
	else if(interval <= 7200.0)
		s = [NSString stringWithFormat:@"1 hour ago"];
	else if(interval <= 86400.0)
		s = [NSString stringWithFormat:@"%d hours ago", (int)interval / 3600];
	else {
		if([[now stringWithFormat:@"yyyy"] isEqual:[created stringWithFormat:@"yyyy"]])
			s = [created stringWithFormat:@"hh:mm a MMM dd'th'" 
								   locale:[[NSLocale alloc] initWithLocaleIdentifier:@"US"]];
		else
			s = [created stringWithFormat:@"hh:mm a MMM dd'th', yyyy" 
								   locale:[[NSLocale alloc] initWithLocaleIdentifier:@"US"]];


	}
	
	return s;
}

- (BOOL)isEqual:(id)object
{
	if([self compare:object] == NSOrderedSame)
		return YES;
	else
		return NO;
}

- (void)dealloc
{
	[user release];
	[created release];
	[text release];
	[source release];
	
	[super dealloc];
}

@end
