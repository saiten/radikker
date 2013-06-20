//
//  RDIPMainViewControllerToolbar.m
//  radikker
//
//  Created by saiten on 10/07/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPMainViewController.h"

#import "AppConfig.h"
#import "RDIPDefines.h"

#import "StatusBarAlert.h"

#import "RDIPAppDelegate.h"
#import "RDIPSettingViewController.h"

@implementation RDIPMainViewController(Toolbar)

- (void)setToolbarPlaying:(BOOL)playing
{
	UIBarButtonItem *playOrPause = playing ? pauseButton : playButton;
	
	self.toolbarItems = [NSArray arrayWithObjects:settingButton, flexibleItem, 
						 volumeButton, flexibleItem, 
						 playOrPause, flexibleItem, 
						 tweetButton, flexibleItem,
             refreshButton, nil];
}

- (void)loadToolbarButtons
{
	flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																 target:nil
																 action:nil];
	
	settingButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear.png"] 
													 style:UIBarButtonItemStylePlain 
													target:self 
													action:@selector(pressSettingButton:)];
  settingButton.accessibilityLabel = 	NSLocalizedString(@"Setting", @"Setting Button");
    
	volumeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"speaker.png"] 
													style:UIBarButtonItemStylePlain 
												   target:self 
												   action:@selector(pressVolumeButton:)];
  volumeButton.accessibilityLabel = NSLocalizedString(@"Volume", @"Volume Button");
	
	playButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
															   target:self 
															   action:@selector(pressPlayButton:)];
  playButton.accessibilityLabel = NSLocalizedString(@"Play", @"Play Button");
	
	pauseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause
																target:self 
																action:@selector(pressPauseButton:)];
  pauseButton.accessibilityLabel = NSLocalizedString(@"Pause", @"Pause Button");
	
	tweetButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chat.png"] 
												   style:UIBarButtonItemStylePlain 
												  target:self 
												  action:@selector(pressTweetButton:)];
  tweetButton.accessibilityLabel = NSLocalizedString(@"Tweet", @"Tweet Button");
  
  refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                                                target:self 
                                                                action:@selector(pressRefreshButton:)];
  refreshButton.accessibilityLabel = NSLocalizedString(@"Refresh", @"Refresh Button");
}

#pragma mark -
#pragma mark Toolbar Buttons Event methods

- (void)pressSettingButton:(id)sender
{
	RDIPSettingViewController *settingViewController = [[[RDIPSettingViewController alloc] init] autorelease];
	UINavigationController *nvc = [[[UINavigationController alloc] initWithRootViewController:settingViewController] autorelease];
	nvc.navigationBar.barStyle = UIBarStyleBlack;
	
	[self.navigationController statusAlertSafelyPresentModalViewController:nvc 
																  animated:YES];
}

- (void)pressVolumeButton:(id)sender
{
	if([mainView isShowVolumebar])
		[mainView hideVolumebar];
	else
		[mainView showVolumebar];
}

- (void)pressPlayButton:(id)sender
{
	[self playRadikoAtSelectStation];
}

- (void)pressPauseButton:(id)sender
{
	[self stopRadiko];
}

- (void)pressTweetButton:(id)sender
{	
	NSString *hashTag = @"";
	if(stations.count > 0) {
		RDIPStation *station = [stations objectAtIndex:selectedStationIndex];
		if(station.tuning) {
			NSDictionary *dic = [[AppConfig sharedInstance] objectForKey:RDIPCONFIG_HASHTAGS];
			hashTag = [dic objectForKey:station.stationId];
		}
	}
	
	[self presentComposeViewControllerWithText:[NSString stringWithFormat:@"%@", hashTag] force:NO];
}

- (void)pressRefreshButton:(id)sender
{
	[self loadStations:YES];
}

@end
