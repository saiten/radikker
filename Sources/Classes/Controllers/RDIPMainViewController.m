//
//  RDIPMainViewController.m
//  radikker
//
//  Created by saiten on 10/03/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPMainViewController.h"

#import "AppConfig.h"
#import "RDIPDefines.h"

#import "RDIPAppDelegate.h"
#import "RDIPStationViewController.h"
#import "RDIPTwitterViewController.h"
#import "RDIPSettingViewController.h"

#import "RDIPEPG.h"
#import "StatusBarAlert.h"

@interface RDIPMainViewController(private)
@end

@implementation RDIPMainViewController

@synthesize radikoStatus;

- (id)init
{
	if((self = [super init])) {
		stations = [[NSMutableArray array] retain];
		stationViewControllers = [[NSMutableDictionary dictionary] retain];

		radikoStatus = RDIP_RADIKOSTATUS_CANPLAY;
		
		radikoPlayer = [[RadikoPlayer alloc] init];
		radikoPlayer.delegate = self;		
	}
	return self;
}

- (void)loadView 
{
	[super loadView];
	if(mainView == nil) {
		mainView = [[RDIPMainView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
		mainView.tunerView.delegate = self;
	}
	
	self.view = mainView;	
}

- (void)loadToolbarButtons
{
	UIBarButtonItem *flexibleItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																				   target:nil
																				   action:nil] autorelease];
	UIBarButtonItem *settingBtn = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear.png"] 
																	style:UIBarButtonItemStylePlain 
																   target:self 
																   action:@selector(pressSettingButton:)] autorelease];
	UIBarButtonItem *volumeBtn = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"speaker.png"] 
																   style:UIBarButtonItemStylePlain 
																  target:self 
																  action:@selector(pressVolumeButton:)] autorelease];
	UIBarButtonItem *tweetBtn = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chat.png"] 
																  style:UIBarButtonItemStylePlain 
																 target:self 
																 action:@selector(pressTweetButton:)] autorelease];

	self.toolbarItems = [NSArray arrayWithObjects:settingBtn, volumeBtn, flexibleItem, tweetBtn, nil];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];	
	[self loadToolbarButtons];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning 
{
	for(UIViewController *vc in [stationViewControllers allValues]) {
		[vc didReceiveMemoryWarning];
	}
	currentViewController = nil;

    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
}

- (void)dealloc 
{
	[stations release];
	
	[stationViewControllers release];

	[mainView release];

	[radikoPlayer stop];
	while(![radikoPlayer isStop])
		[NSThread sleepForTimeInterval:0.1];

	[radikoPlayer release];

    [super dealloc];
}

#pragma mark -
#pragma mark lifecycle methods

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	[self.navigationController setToolbarHidden:NO animated:YES];	
	[self loadStations];
	
	[currentViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];

	[currentViewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated 
{
    [super viewWillDisappear:animated];

	[currentViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];

	[currentViewController viewDidDisappear:animated];
}

#pragma mark -
#pragma mark original methods

- (void)playRadiko
{
	[[StatusBarAlert sharedInstance] showStatus:[NSString stringWithFormat:@"Connecting.. %@", radikoPlayer.channel] 
									   animated:YES];
	[radikoPlayer play];
}

- (void)stopRadiko
{
	[[StatusBarAlert sharedInstance] showStatus:@"Disconnecting.." 
									   animated:YES];
	[radikoPlayer stop];
}

- (BOOL)isPlayRadiko
{
	RADIKOPLAYER_STATUS st = radikoPlayer.status;
	return st == RADIKOPLAYER_STATUS_CONNECT 
	    || st == RADIKOPLAYER_STATUS_DISCONNECT 
	    || st == RADIKOPLAYER_STATUS_PLAY;
}

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

	[self presentComposeViewControllerWithText:hashTag force:NO];
}

- (void)createViewControllers
{
	NSMutableArray *removeKeys = [NSMutableArray arrayWithArray:[stationViewControllers allKeys]];
	
	for(RDIPStation *station in stations) {
		UIViewController *controller = [stationViewControllers objectForKey:station.stationId];
		if(controller) {
			[removeKeys removeObject:station.stationId];
		} else {
			if([station isKindOfClass:[RDIPTwitterStation class]]) {
				controller = [[[RDIPTwitterViewController alloc] init] autorelease];
			} else {
				RDIPStationViewController *stationController = [[[RDIPStationViewController alloc] initWithStation:station] autorelease];
				stationController.delegate = self;
				controller = stationController;
			}
			[stationViewControllers setValue:controller forKey:station.stationId];
		}
	}
	[stationViewControllers removeObjectsForKeys:removeKeys];	
}

- (NSArray*)stationsWithKindOfClass:(Class)class
{
	NSMutableArray *arr = [NSMutableArray array];
	for(RDIPStation *station in stations) {
		if([station isKindOfClass:class])
			[arr addObject:station];
	}
	
	if(arr.count > 0)
		return arr;
	else
		return nil;
}

- (void)setTwitterStation
{
	NSString *userId = [[AppSetting sharedInstance] objectForKey:RDIPSETTING_USERID];
	NSArray *twitArr = [self stationsWithKindOfClass:[RDIPTwitterStation class]];
	
	if(userId && !twitArr) {
		RDIPTwitterStation *twitterStation = [[[RDIPTwitterStation alloc] init] autorelease];
		[stations addObject:twitterStation];			
	} else if(!userId) {
		for(RDIPStation *s in twitArr)
			[stations removeObject:s];
	}
}

- (void)reloadTuner
{
	// set twitter station
	[self setTwitterStation];
	
	[self createViewControllers];
	
	mainView.tunerView.loading = NO;
	[mainView.tunerView reloadView];
	
	if(selectedStationIndex >= stations.count)
		selectedStationIndex = stations.count-1;
	
	if(tunedStationIndex >= stations.count)
		tunedStationIndex = stations.count-1;	
	
	if(stations.count > 0) {
		mainView.tunerView.selectedIndex = selectedStationIndex;
		mainView.tunerView.tunedIndex = tunedStationIndex;
		[self tunerView:nil didSelectStationForItemAtIndex:selectedStationIndex];
	}
}

#pragma mark -
#pragma mark RadikoPlayerDelegate

- (void)radikoPlayerDidPlay:(RadikoPlayer *)aRadikoPlayer
{
	[[StatusBarAlert sharedInstance] hideStatusAnimated:YES];
	replay = NO;

	if([currentViewController isKindOfClass:[RDIPStationViewController class]])
		[(RDIPStationViewController*)currentViewController nowOnAir];
}

- (void)radikoPlayerDidStop:(RadikoPlayer *)aRadikoPlayer
{
	if(replay) {
		[self playRadiko];
	} else {
		[[StatusBarAlert sharedInstance] hideStatusAnimated:YES];
	}
}

- (void)radikoPlayerDidConnectRTMPStream:(RadikoPlayer*)aRadikoPlayer
{
	[[StatusBarAlert sharedInstance] showStatus:[NSString stringWithFormat:@"Buffering.. %@", radikoPlayer.channel] 
									   animated:YES];
}

- (void)radikoPlayerDidDisconnectRTMPStream:(RadikoPlayer*)aRadikoPlayer
{
	[[StatusBarAlert sharedInstance] showStatus:@"Disconnected."
									   animated:YES];
}


#pragma mark -
#pragma mark RDIPStationClient methods

- (void)loadStations
{
	@synchronized(stationClient) {
		if(stationClient != nil)
			return;

		mainView.tunerView.loading = YES;
		
		if(radikoStatus != RDIP_RADIKOSTATUS_CANPLAY) {
			[mainView.tunerView reloadView];
			return;
		}
		
		if(!lastStationUpdate || [[NSDate date] timeIntervalSinceDate:lastStationUpdate] > 60 * 60 * 24) {
			stationClient = [[RDIPStationClient alloc] initWithDelegate:self];
			[stationClient getStations];
			
			[lastStationUpdate release];
			lastStationUpdate = [[NSDate date] retain];
			
			[stations removeAllObjects];
			[mainView.tunerView reloadView];
		} else {
			[self performSelector:@selector(reloadTuner) withObject:nil afterDelay:0.1];
		}
	}
}

- (void)stationClient:(RDIPStationClient*)aStationClient didGetStations:(NSArray*)aStations
{
	if(aStations.count > 0) {
		radikoStatus = RDIP_RADIKOSTATUS_CANPLAY;
	} else {
		radikoStatus = RDIP_RADIKOSTATUS_NOTSERVICESAREA;
	}
	
	areaCode = [aStationClient.areaCode retain];
	areaName = [aStationClient.areaName retain];
	
	[[RDIPEPG sharedInstance] setAreaId:areaCode];

	[stations removeAllObjects];
	[stations addObjectsFromArray:aStations];

	[mainView.footerView setAreaName:areaName];
	
	[stationClient autorelease];
	stationClient = nil;

	selectedStationIndex = tunedStationIndex = 0;
	[self reloadTuner];
}

- (void)stationClient:(RDIPStationClient*)aStationClient didFailWithError:(NSError*)error
{
	NSLog(@"stationClient failed : %@", [error description]);

	mainView.tunerView.loading = NO;
	
	[stationClient autorelease];
	stationClient = nil;
}

#pragma mark -
#pragma mark RDIPTunerViewDelegate methods

- (NSInteger)numberOfStationsInTunerView:(RDIPTunerView *)tunerView
{
	return stations.count;
}

- (RDIPStation*)tunerView:(RDIPTunerView *)tunerView stationForItemAtIndex:(NSInteger)index
{
	return [stations objectAtIndex:index];
}

- (void)tunerView:(RDIPTunerView *)tunerView didSelectStationForItemAtIndex:(NSInteger)index
{
	BOOL animated = NO;
	selectedStationIndex = index;
	RDIPStation *selectStation = [stations objectAtIndex:index];
	UIViewController *newController = [stationViewControllers objectForKey:selectStation.stationId];

	if(newController && currentViewController != newController) {
		UIViewController *oldController = currentViewController;
		currentViewController = newController;
		
		[oldController viewWillDisappear:animated];
		[newController viewWillAppear:animated];
		
		mainView.containerView = newController.view;
		
		[oldController viewDidDisappear:animated];
		[newController viewDidAppear:animated];
	}
}

- (void)tunerView:(RDIPTunerView *)tunerView didTuneStationForItemAtIndex:(NSInteger)index
{
	tunedStationIndex = index;
	RDIPStation *station = [stations objectAtIndex:index];
	if(station) {
		[radikoPlayer setChannel:station.stationId];
		if(radikoPlayer.status == RADIKOPLAYER_STATUS_PLAY 
		   || radikoPlayer.status == RADIKOPLAYER_STATUS_CONNECT) {
			[self stopRadiko];
			replay = YES;
		} if(radikoPlayer.status == RADIKOPLAYER_STATUS_STOP) {
			[self playRadiko];
		}
	}
	
}

#pragma mark -
#pragma mark RDIPStationViewControllerDelegate methods

- (BOOL)stationViewController:(RDIPStationViewController*)viewController nowOnAirAtStation:(RDIPStation*)station
{
	if(!(radikoPlayer.status == RADIKOPLAYER_STATUS_CONNECT || radikoPlayer.status == RADIKOPLAYER_STATUS_PLAY))
		return NO;

	if([radikoPlayer.channel isEqualToString:station.stationId])
		return YES;
	else 
		return NO;
}


@end

