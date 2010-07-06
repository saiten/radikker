//
//  RDIPDirectMessageViewController.m
//  radikker
//
//  Created by saiten  on 10/04/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPDirectMessageViewController.h"


@implementation RDIPDirectMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.title = @"DirectMessages";
}	

// override method
- (void)loadTimelineWithParams:(NSDictionary*)params
{
	[self cancel];
	
	activeClient = [[RDIPTwitterClient alloc] initWithDelegate:self];
	[activeClient getDirectMessageWithParams:params];
}

@end
