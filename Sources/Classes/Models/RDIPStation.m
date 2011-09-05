//
//  RDIPStation.m
//  radikker
//
//  Created by saiten on 10/03/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPStation.h"
#import "GDataXMLNode.h"

@class RDIPStationViewController;

@implementation RDIPStation

@synthesize stationId, stationName, logoUrl, feedUrl, bannerUrl, tuning;

- (id)initWithGDataXMLNode:(GDataXMLNode*)stationNode
{
	if((self = [super init])) {

		for(GDataXMLNode *childNode in stationNode.children) {
			NSString *tagName = [[childNode name] lowercaseString];

			if([tagName isEqualToString:@"id"])
				stationId = [[childNode stringValue] retain];
			else if([tagName isEqualToString:@"name"])
				stationName = [[childNode stringValue] retain];
			else if([tagName isEqualToString:@"logo_medium"])
				logoUrl = [[childNode stringValue] retain];
			else if([tagName isEqualToString:@"feed"])
				feedUrl = [[childNode stringValue] retain];
			else if([tagName isEqualToString:@"banner"])
				bannerUrl = [[childNode stringValue] retain];
			
			tuning = YES;
		}

	}
	return self;
}

+ (id)stationWithGDataXMLNode:(GDataXMLNode*)stationNode
{
	return [[[RDIPStation alloc] initWithGDataXMLNode:stationNode] autorelease];
}

- (void)dealloc
{
	[stationId release];
	[stationName release];
	[logoUrl release];
	[feedUrl release];
	[bannerUrl release];
	
	[super dealloc];
}

@end

@implementation RDIPTwitterStation

- (id)init
{
	if((self = [super init])) {
		stationId = @"TWIT";
		stationName = @"twitter";
		NSString *logoPath = [[[NSBundle mainBundle] pathForResource:@"twitter" ofType:@"png"] retain];
		logoUrl = [[[NSURL fileURLWithPath:logoPath] absoluteString] retain];
		feedUrl = nil;
		bannerUrl = nil;
		tuning = NO;
	}
	return self;
}

@end

@implementation RDIPNoServiceStation

- (id)init
{
	if((self = [super init])) {
		stationId = @"NOSV";
		stationName = @"noservice";
		NSString *logoPath = [[[NSBundle mainBundle] pathForResource:@"warning" ofType:@"png"] retain];
		logoUrl = [[[NSURL fileURLWithPath:logoPath] absoluteString] retain];
		feedUrl = nil;
		bannerUrl = nil;
		tuning = NO;
	}
	return self;
}

@end

@implementation RDIPUpdateStateStation

- (id)init
{
	if((self = [super init])) {
		stationId = @"UPST";
		stationName = @"updatestate";
		logoUrl = nil;
		feedUrl = nil;
		bannerUrl = nil;
		tuning = NO;
	}
	return self;
}

@end

@implementation RDIPRadiruStation

- (id)initWithChannel:(NSString*)channel
{
	if((self = [super init])) {
		stationId = channel;
    NSString *locKey = [NSString stringWithFormat:@"radiru_%@", channel];
		stationName =  [NSLocalizedString(locKey, locKey) retain];
		NSString *logoPath = [[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"radiru_%@", channel] ofType:@"png"] retain];
		logoUrl = [[[NSURL fileURLWithPath:logoPath] absoluteString] retain];
		feedUrl = nil;
		bannerUrl = nil;
		tuning = YES;
	}
	return self;
}

@end

