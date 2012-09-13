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
#import "RDIPSettingViewController.h"
#import "RDIPStationViewController.h"

#import "RDIPEPG.h"
#import "StatusBarAlert.h"

@interface RDIPMainViewController(private)
@end

@implementation RDIPMainViewController

@synthesize radikoStatus, radikoPlayer;

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

- (void)viewDidLoad 
{
  [super viewDidLoad];
	[self loadToolbarButtons];
	[self setToolbarPlaying:NO];

	// enable remote control
	UIApplication *app = [UIApplication sharedApplication];
	if([app respondsToSelector:@selector(beginReceivingRemoteControlEvents)])
		[app beginReceivingRemoteControlEvents];	

	reachability = [[Reachability reachabilityForInternetConnection] retain];
	[reachability startNotifier];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(reachabilityChanged:)
												 name:kReachabilityChangedNotification
											   object:nil];
	[self updateStatus];	
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

  [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                  name:kReachabilityChangedNotification
                                                object:nil];
	[reachability stopNotifier];
	[reachability release];
	reachability = nil;
}

- (void)dealloc 
{
	[nowOnAir release];
	[stations release];

	[flexibleItem release];
	[settingButton release];
	[volumeButton release];
	[playButton release];
	[pauseButton release];
	[tweetButton release];
	
	[currentViewController release];
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

	[currentViewController viewWillAppear:animated];

	tweetButton.enabled = ([[AppSetting sharedInstance] objectForKey:RDIPSETTING_USERID] != nil);
	playButton.enabled = (radikoStatus == RDIP_RADIKOSTATUS_CANPLAY);
	
	[self reloadTuner];
}

- (BOOL)canBecomeFirstResponder 
{
	return YES;
}

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
	[currentViewController viewDidAppear:animated];
	[self becomeFirstResponder];
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
	[self resignFirstResponder];
}

#pragma mark -
#pragma mark RDIPStationClient methods

- (void)loadStations:(BOOL)forceRefresh
{
  if(!radikoPlayer.areaCode) {
    [radikoPlayer authenticate];
    return;
  }
  
	@synchronized(stationClient) {
		if(stationClient != nil)
			return;

		if(radikoStatus != RDIP_RADIKOSTATUS_CANPLAY) {
			[self reloadTuner];
			return;
		}
		
    NSArray *tuneStations = [self stationsWithTuningItem];
    
		if(!tuneStations || forceRefresh) {
			stationClient = [[RDIPStationClient alloc] initWithDelegate:self areaCode:radikoPlayer.areaCode];
			[stationClient getStations];
			
			[lastStationUpdate release];
			lastStationUpdate = [[NSDate date] retain];
			
			[stations removeAllObjects];
			[self reloadTuner];
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
  [self setRadiruStation];
	[self reloadTuner];
}

- (void)stationClient:(RDIPStationClient*)aStationClient didFailWithError:(NSError*)error
{
	NSLog(@"stationClient failed : %@", [error description]);

	mainView.tunerView.loading = NO;

	radikoStatus = RDIP_RADIKOSTATUS_NOTSERVICESAREA;
	[self reloadTuner];
	
	[stationClient autorelease];
	stationClient = nil;
}

- (void)setRadiruStation
{
	NSArray *arr = [self stationsWithKindOfClass:[RDIPTwitterStation class]];
  if(!arr) {
    NSArray *channels = [NSArray arrayWithObjects:@"R1", @"R2", @"FM", nil];
    for(NSString *channel in channels) {
      RDIPRadiruStation *radiruStation = [[[RDIPRadiruStation alloc] initWithChannel:channel] autorelease];
      [stations addObject:radiruStation];
    }
  }
}

#pragma mark -
#pragma mark remote control event methods

- (void)remoteControlReceivedWithEvent:(UIEvent*)event
{
	if(event.type == UIEventTypeRemoteControl) {
		switch(event.subtype) {
			case UIEventSubtypeRemoteControlTogglePlayPause:
				if(radikoPlayer.status == RADIKOPLAYER_STATUS_PLAY)
					[self stopRadiko];
				else
					[self playRadiko];
				break;
			case UIEventSubtypeRemoteControlPlay:
				[self playRadiko];
				break;
			case UIEventSubtypeRemoteControlPause:
			case UIEventSubtypeRemoteControlStop:
				[self stopRadiko];
				break;
		}
	}
}


@end

