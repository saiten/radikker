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
#import "AppSetting.h"
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
  
  if(![station isKindOfClass:[RDIPRadiruStation class]]) {
    listButton  = [[RDIPSquareButton alloc] initWithImage:[UIImage imageNamed:@"list.png"]];
    listButton.accessibilityLabel = NSLocalizedString(@"Program List", @"Program List");
  }
  
  tweetButton = [[RDIPSquareButton alloc] initWithImage:[UIImage imageNamed:@"bird.png"]];
  tweetButton.accessibilityLabel = NSLocalizedString(@"Tweet List", @"Tweet List");
  
  NSMutableArray *buttons = [NSMutableArray array];
  [buttons addObject:infoButton];
  
  if(![station isKindOfClass:[RDIPRadiruStation class]]) {
    [buttons addObject:listButton];
  }
  if([[AppSetting sharedInstance] objectForKey:RDIPSETTING_USERID] != nil) {
    [buttons addObject:tweetButton];
  }

  return buttons;
}

- (NSArray*)loadViewControllers
{
	RDIPStationInfoViewController *infoViewController = [[[RDIPStationInfoViewController alloc] initWithStation:station] autorelease];

  RDIPProgramListViewController *programListViewController = nil;
  if(![station isKindOfClass:[RDIPRadiruStation class]])
    programListViewController = [[[RDIPProgramListViewController alloc] initWithStation:station] autorelease];									

	NSDictionary *hashTags = [[AppConfig sharedInstance] objectForKey:RDIPCONFIG_HASHTAGS];
	NSString *hashTag = [hashTags objectForKey:station.stationId];
    if(!hashTag) {
        hashTag = [hashTags objectForKey:@"DEFAULT"];
    }
	RDIPStationTimelineViewController *timelineViewController = [[[RDIPStationTimelineViewController alloc] initWithHashTag:hashTag] autorelease];
	
  if(![station isKindOfClass:[RDIPRadiruStation class]])
    return [NSArray arrayWithObjects:infoViewController, programListViewController, timelineViewController, nil];
  else
    return [NSArray arrayWithObjects:infoViewController, timelineViewController, nil];
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
