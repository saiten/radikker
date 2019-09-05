//
//  RDIPMainViewController.m
//  radikker
//
//  Created by saiten on 10/03/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <GoogleMobileAds/GoogleMobileAds.h>
#import "RDIPMainViewController.h"

#import "AppConfig.h"
#import "RDIPDefines.h"

#import "RDIPAppDelegate.h"
#import "RDIPSettingViewController.h"
#import "RDIPStationViewController.h"

#import "RDIPEPG.h"
#import "StatusBarAlert.h"
#import "SharedImageStore.h"
#import "environment.h"

@interface RDIPMainViewController(private) <GADBannerViewDelegate, MPPlayableContentDataSource, MPPlayableContentDelegate>
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
	
    self.edgesForExtendedLayout = UIRectEdgeNone;
	self.view = mainView;
}

- (void)viewDidLoad 
{
  [super viewDidLoad];
	[self loadToolbarButtons];
	[self setToolbarPlaying:NO];

    NSLog(@"Google Mobile Ads SDK version: %@", [GADRequest sdkVersion]);
    mainView.bannerView.adUnitID = ADMOB_ADUNIT_ID;
    mainView.bannerView.rootViewController = self;
    mainView.bannerView.delegate = self;
    [mainView.bannerView setHidden:true];
    
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
    
    [MPPlayableContentManager sharedContentManager].dataSource = self;
    [MPPlayableContentManager sharedContentManager].delegate = self;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(RDIPEpgGetProgramNotification:)
                                                 name:RDIPEPG_GETPROGRAM_NOTIFICATION
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(SharedImageStoreGetNewImageNotification:)
                                                 name:SHAREDIMAGESTORE_GETNEWIMAGE_NOTIFICATION
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
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SHAREDIMAGESTORE_GETNEWIMAGE_NOTIFICATION
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:RDIPEPG_GETPROGRAM_NOTIFICATION
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

- (void)updateAdWithURLString:(NSString *)urlString
{
    if(urlString && urlString.length > 0) {
        GADRequest *request = [GADRequest request];
        request.contentURL = urlString;
        [mainView.bannerView loadRequest:request];
    }
}

- (void)loadStations:(BOOL)forceRefresh
{
  if(!radikoPlayer.areaCode) {
      refreshButton.enabled = NO;
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
            
            refreshButton.enabled = NO;
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
    //[self setRadiruStation];
	[self reloadTuner];
    refreshButton.enabled = YES;
}

- (void)stationClient:(RDIPStationClient*)aStationClient didFailWithError:(NSError*)error
{
	DLog(@"stationClient failed : %@", [error description]);

    [self unavailableTuner];
	
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
				if(radikoPlayer.status == RADIKOPLAYER_STATUS_STOP) {
					[self playRadiko];
				} else {
					[self stopRadiko];
                }
				break;
			case UIEventSubtypeRemoteControlPlay:
				[self playRadiko];
				break;
            case UIEventSubtypeRemoteControlNextTrack:
                if(tunedStationIndex < stations.count-1) {
                    tunedStationIndex++;
                } else {
                    tunedStationIndex = 0;
                }
                mainView.tunerView.tunedIndex = tunedStationIndex;
                [self playRadiko];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                if(tunedStationIndex > 0) {
                    tunedStationIndex--;
                } else {
                    tunedStationIndex = stations.count-1;
                }
                mainView.tunerView.tunedIndex = tunedStationIndex;
                [self playRadiko];
                break;
			case UIEventSubtypeRemoteControlPause:
			case UIEventSubtypeRemoteControlStop:
				[self stopRadiko];
				break;
		}
	}
}

#pragma mark - Google Mobile Ads

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    NSLog(@"admob success");
    [mainView.bannerView setHidden:false];
    [mainView layoutIfNeeded];
    
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"admob error : %@", error);
    [mainView.bannerView setHidden:true];
    [mainView layoutIfNeeded];
}

#pragma mark - MPPlayableContentDataSource

- (MPContentItem *)contentItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = [indexPath indexAtPosition:0];
    RDIPStation *station = [stations objectAtIndex:index];
    RDIPProgram *program = [[RDIPEPG sharedInstance] programForStationAtNow:station.stationId];
    
    MPContentItem *item = [[[MPContentItem alloc] initWithIdentifier:station.stationId] autorelease];
    item.title = station.stationName;
    UIImage *image = [[SharedImageStore sharedInstance] getImage:station.logoUrl];
    if(image) {
        item.artwork = [[[MPMediaItemArtwork alloc] initWithImage:image] autorelease];
    }
    item.subtitle = program.title;
    item.container = NO;
    if([item respondsToSelector:@selector(setExplicitContent:)]) {
        item.explicitContent = YES;
    }
    if([item respondsToSelector:@selector(setStreamingContent:)]) {
        item.streamingContent = YES;
    }
    item.playable = station.tuning;
    item.playbackProgress = nowOnAir == program ? -1.0 : 0.0;
    
    return item;
}

- (NSInteger)numberOfChildItemsAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = 0;
    for(RDIPStation *station in stations) {
        if(station.tuning) count++;
    }
    return count;
}

#pragma mark - MPPlayableContentDelegate

- (BOOL)childItemsDisplayPlaybackProgressAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)playableContentManager:(MPPlayableContentManager *)contentManager initiatePlaybackOfContentItemAtIndexPath:(NSIndexPath *)indexPath
             completionHandler:(void (^)(NSError * _Nullable))completionHandler
{
    NSInteger index = [indexPath indexAtPosition:0];

    if(index >= 0 && index < stations.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            tunedStationIndex = index;
            mainView.tunerView.tunedIndex = tunedStationIndex;
            [self playRadiko];
            completionHandler(nil);
        });
    } else {
        completionHandler(nil);
    }
}

- (void)playableContentManager:(MPPlayableContentManager *)contentManager didUpdateContext:(MPPlayableContentManagerContext *)context
{
}

#pragma mark - notifications

- (void)RDIPEpgGetProgramNotification:(NSNotification*)notification
{
    NSError *err = [[notification userInfo] objectForKey:RDIPEPG_KEY_ERROR];
    if(err) {
        // TODO
    } else {
        [[MPPlayableContentManager sharedContentManager] reloadData];
    }
}

- (void)SharedImageStoreGetNewImageNotification:(NSNotification*)notifiation
{
    NSString *requestUrl = [[notifiation userInfo] objectForKey:SHAREDIMAGESTORE_KEY_REQUESTURL];
    
    BOOL shouldReload = NO;
    for(RDIPStation *station in stations) {
        if([requestUrl isEqualToString:station.logoUrl]) {
            shouldReload = YES;
        }
    }
    
    if(shouldReload) {
        [[MPPlayableContentManager sharedContentManager] reloadData];
    }
}


@end

