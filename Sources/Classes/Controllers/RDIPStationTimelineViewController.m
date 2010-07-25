//
//  RDIPStationTimelineViewController.m
//  radikker
//
//  Created by saiten on 10/04/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPStationTimelineViewController.h"

@implementation RDIPStationTimelineViewController

@synthesize hashTag;

- (id)initWithHashTag:(NSString*)aHashTag
{
	if(self = [super init]) {
		hashTag = [aHashTag retain];
		if(hashTag)
			[currentKeyword setString:hashTag];
	}
	return self;
}

- (void)dealloc
{
	[hashTag release];
	[super dealloc];
}

@end
