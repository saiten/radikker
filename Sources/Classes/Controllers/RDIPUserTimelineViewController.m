//
//  RDIPUserTimelineViewController.m
//  radikker
//
//  Created by saiten on 10/05/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPUserTimelineViewController.h"

@implementation RDIPUserTimelineViewController

@synthesize screenName;

- (id)initWithScreenName:(NSString*)aScreenName
{
	if(self = [super init]) {
		screenName = [aScreenName retain];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.title = [NSString stringWithFormat:@"@%@", screenName];
}	

- (void)dealloc
{
	[screenName release];
	[super dealloc];
}

// override method
- (void)loadTimelineWithParams:(NSDictionary*)params
{
	[self cancel];
	
	activeClient = [[RDIPTwitterClient alloc] initWithDelegate:self];
	[activeClient getUserTimeline:screenName params:params];
}

@end
