//
//  RDIPProgram.m
//  radikker
//
//  Created by saiten on 10/04/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPProgram.h"
#import "GDataXMLNode.h"

@implementation RDIPProgram

@synthesize title, fromTime, toTime, duration;
@synthesize performer, description, info, url;

+ (id)programWithGdataXMLNode:(GDataXMLNode*)programNode
{
	return [[[RDIPProgram alloc] initWithGDataXMLNode:programNode] autorelease];
}

- (id)initWithGDataXMLNode:(GDataXMLNode*)programNode
{
	if(self = [super init]) {
		NSDateFormatter *fmt = [[[NSDateFormatter alloc] init] autorelease];
		[fmt setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"US"] autorelease]];
        [fmt setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
		[fmt setDateFormat:@"yyyyMMddHHmmss"];
		
		for(GDataXMLNode *attr in [(GDataXMLElement*)programNode attributes]) {
			NSString *attrName = [attr name];
			if([attrName isEqualToString:@"ft"]) {
				fromTime = [[fmt dateFromString:[attr stringValue]] retain];
			} if([attrName isEqualToString:@"to"]) {
				toTime = [[fmt dateFromString:[attr stringValue]] retain];
			} if([attrName isEqualToString:@"dur"]) {
				duration = [[attr stringValue] intValue];
			}
		}
		
		for(GDataXMLNode *childNode in programNode.children) {
			NSString *tagName = [[childNode name] lowercaseString];

			if([tagName isEqualToString:@"title"])
				title = [[childNode stringValue] retain];
			else if([tagName isEqualToString:@"pfm"])
				performer = [[childNode stringValue] retain];
			else if([tagName isEqualToString:@"desc"])
				description = [[childNode stringValue] retain];
			else if([tagName isEqualToString:@"url"])
				url = [[childNode stringValue] retain];
			else if([tagName isEqualToString:@"info"])
				info = [[childNode stringValue] retain];
		}		
	}

	return self;
}

- (id)init
{
	if(self = [super init]) {
	}
	return self;
}

+ (id)emptyProgram
{
	return [[[RDIPProgram alloc] init] autorelease];
}

- (NSComparisonResult)compareDate:(RDIPProgram*)another
{
	return [fromTime compare:another.fromTime];
}

- (void)dealloc
{
	[title release];
	[fromTime release];
	[toTime release];
	[performer release];
	[description release];
	[info release];
	[url release];
	[super dealloc];
}

@end
