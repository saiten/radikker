//
//  RDIPStationViewController.m
//  radikker
//
//  Created by saiten on 10/04/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPStationViewController.h"
#import "RDIPStationInfoViewController.h"
#import "RDIPProgramListViewController.h"
#import "RDIPStationTimelineViewController.h"
#import "AppConfig.h"
#import "RDIPDefines.h"

@implementation RDIPStationViewController

@synthesize delegate;

- (id)initWithStation:(RDIPStation *)s
{
	if((self = [super init])) {
		station = [s retain];
	}
	return self;
}

- (NSArray*)loadButtons
{
	infoButton  = [[RDIPSquareButton alloc] initWithImage:[UIImage imageNamed:@"headphones.png"]];
    infoButton.accessibilityLabel = NSLocalizedString(@"Program", @"Program Information");
	listButton  = [[RDIPSquareButton alloc] initWithImage:[UIImage imageNamed:@"list.png"]];
    listButton.accessibilityLabel = NSLocalizedString(@"Program List", @"Program List");
	tweetButton = [[RDIPSquareButton alloc] initWithImage:[UIImage imageNamed:@"bird.png"]];
    tweetButton.accessibilityLabel = NSLocalizedString(@"Tweet List", @"Tweet List");
    
	return [NSArray arrayWithObjects:infoButton, listButton, tweetButton, nil];
}

- (NSArray*)loadViewControllers
{
	RDIPStationInfoViewController *infoViewController = [[[RDIPStationInfoViewController alloc] initWithStation:station] autorelease];

	RDIPProgramListViewController *programListViewController = [[[RDIPProgramListViewController alloc] initWithStation:station] autorelease];																
	
	NSString *hashTag = [(NSDictionary*)[[AppConfig sharedInstance] objectForKey:RDIPCONFIG_HASHTAGS] objectForKey:station.stationId];
	RDIPStationTimelineViewController *timelineViewController = [[[RDIPStationTimelineViewController alloc] initWithHashTag:hashTag] autorelease];
	
	return [NSArray arrayWithObjects:infoViewController, programListViewController, timelineViewController, nil];
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
	[station release];
	[infoButton release];
	[listButton release];
	[tweetButton release];
	
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self nowOnAir];
}

- (BOOL)nowOnAir
{
	BOOL b = NO;
	
	if(delegate && [delegate respondsToSelector:@selector(stationViewController:nowOnAirAtStation:)])
		b = [delegate stationViewController:self nowOnAirAtStation:station];
	
	if(b != _nowOnAir) {
		_nowOnAir = b;
		if(_nowOnAir)
			[infoButton setBadge:@"On Air"];
		else
			[infoButton setBadge:nil];
	}
	
	return _nowOnAir;
}

@end
