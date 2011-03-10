//
//  RDIPTwitterViewController.m
//  radikker
//
//  Created by saiten on 10/04/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPTwitterViewController.h"
#import "RDIPSquareButton.h"
#import "RDIPHomeTimelineViewController.h"
#import "RDIPMentionsTimelineViewController.h"
#import "RDIPDirectMessageViewController.h"
#import "RDIPSearchTimelineViewController.h"

@implementation RDIPTwitterViewController

- (id)init
{
	if((self = [super init])) {
	}
	return self;
}

- (NSArray*)loadButtons
{
	RDIPSquareButton *homeButton     = [[[RDIPSquareButton alloc] initWithImage:[UIImage imageNamed:@"house.png"]] autorelease];
    homeButton.accessibilityLabel = NSLocalizedString(@"Home", @"Home");
	RDIPSquareButton *mentionsButton = [[[RDIPSquareButton alloc] initWithImage:[UIImage imageNamed:@"atmark.png"]] autorelease];
    mentionsButton.accessibilityLabel = NSLocalizedString(@"Mentions", @"Mentions");
	RDIPSquareButton *dmButton       = [[[RDIPSquareButton alloc] initWithImage:[UIImage imageNamed:@"envelope.png"]] autorelease];
    dmButton.accessibilityLabel = NSLocalizedString(@"Direct Messages", @"Direct Messages");
	RDIPSquareButton *searchButton   = [[[RDIPSquareButton alloc] initWithImage:[UIImage imageNamed:@"magnifying-glass.png"]] autorelease];
    searchButton.accessibilityLabel = NSLocalizedString(@"Search", @"Search");
    
	return [NSArray arrayWithObjects:homeButton, mentionsButton, dmButton, searchButton, nil];
}

- (NSArray*)loadViewControllers
{
	RDIPHomeTimelineViewController *homeViewController = [[[RDIPHomeTimelineViewController alloc] init] autorelease];
	RDIPMentionsTimelineViewController *mentionsViewController = [[[RDIPMentionsTimelineViewController alloc] init] autorelease];
	RDIPDirectMessageViewController *dmViewController = [[[RDIPDirectMessageViewController alloc] init] autorelease];
	RDIPSearchTimelineViewController *searchViewController   = [[[RDIPSearchTimelineViewController alloc] init] autorelease];
	
	return [NSArray arrayWithObjects:homeViewController, mentionsViewController, dmViewController, searchViewController, nil];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
}

- (void)dealloc 
{
    [super dealloc];
}


#pragma mark -
#pragma mark lifecycle methods

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	
}

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated 
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
}


@end