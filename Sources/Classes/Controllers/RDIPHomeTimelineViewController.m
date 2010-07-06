//
//  RDIPHomeTimelineViewController.m
//  radikker
//
//  Created by saiten on 10/04/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPHomeTimelineViewController.h"


@implementation RDIPHomeTimelineViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.title = @"Home";
}	

// override method
- (void)loadTimelineWithParams:(NSDictionary*)params
{
	[self cancel];
	
	activeClient = [[RDIPTwitterClient alloc] initWithDelegate:self];
	[activeClient getHomeTimelineWithParams:params];
}

@end
