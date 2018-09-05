//
//  RDIPMainViewController.h
//  radikker
//
//  Created by saiten on 10/03/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "Reachability.h"

#import "AppSetting.h"

#import "RDIPDefines.h"
#import "RadikoPlayer.h"
#import "RDIPMainView.h"
#import "RDIPStationClient.h"

#import "RDIPReverseGeocoder.h"
#import "RDIPEPG.h"

typedef enum {
	RDIP_RADIKOSTATUS_CANPLAY,
	RDIP_RADIKOSTATUS_CHECKLOCATION,
	RDIP_RADIKOSTATUS_NOTSERVICESAREA,
	RDIP_RADIKOSTATUS_NOTSUPPORTDEVICE
} RDIP_RADIKOSTATUS;

@interface RDIPMainViewController : UIViewController {
	RDIPMainView *mainView;

	UIBarButtonItem *flexibleItem;
	UIBarButtonItem *settingButton;
	UIBarButtonItem *volumeButton;
	UIBarButtonItem *playButton;
	UIBarButtonItem *pauseButton;
	UIBarButtonItem *tweetButton;	
	UIBarButtonItem *refreshButton;
	
	UIViewController *currentViewController;
	NSMutableDictionary *stationViewControllers;

	NSMutableArray *stations;
	NSString *areaCode;
	NSString *areaName;

	NSInteger selectedStationIndex;
	NSInteger tunedStationIndex;
	
	RDIPStationClient *stationClient;
	NSDate *lastStationUpdate;

	RDIP_RADIKOSTATUS radikoStatus;
	BOOL replay;
	RadikoPlayer *radikoPlayer;
	
	Reachability *reachability;
    
    NSTimer *updateTimer;
    RDIPProgram *nowOnAir;
}

@property(nonatomic, readwrite) RDIP_RADIKOSTATUS radikoStatus;
@property(nonatomic, readonly) RadikoPlayer *radikoPlayer;

- (void)loadStations:(BOOL)forceRefresh;
- (void)updateAdWithURLString:(NSString *)urlString;
@end

@interface RDIPMainViewController(RadikoPlayerDelegate)
- (void)playRadikoAtSelectStation;
- (void)playRadiko;
- (void)stopRadiko;
@end

@interface RDIPMainViewController(TunerViewDelegate) <RDIPTunerViewDelegate>
- (NSArray*)stationsWithTuningItem;
- (NSArray*)stationsWithKindOfClass:(Class)class;
- (void)reloadTuner;
- (void)unavailableTuner;
@end

@interface RDIPMainViewController(UpdateStatus) <CLLocationManagerDelegate, RDIPReverseGeocoderDelegate>
- (void)updateStatus;
@end

@interface RDIPMainViewController(Toolbar)
- (void)setToolbarPlaying:(BOOL)playing;
- (void)loadToolbarButtons;
@end

