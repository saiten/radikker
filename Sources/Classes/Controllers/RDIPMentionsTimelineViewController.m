//
//  RDIPMentionsTimelineViewController.m
//  radikker
//
//  Created by saiten  on 10/04/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPMentionsTimelineViewController.h"


@implementation RDIPMentionsTimelineViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.title = @"Mentions";
}	

// override method
- (void)loadTimelineWithParams:(NSDictionary*)params
{
	[self cancel];
	
	activeClient = [[RDIPTwitterClient alloc] initWithDelegate:self];
	[activeClient getMentionsWithParams:params];
}

@end
