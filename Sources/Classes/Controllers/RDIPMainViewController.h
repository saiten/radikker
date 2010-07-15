//
//  RDIPMainViewController.h
//  radikker
//
//  Created by saiten on 10/03/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "Reachability.h"

#import "AppSetting.h"

#import "RDIPDefines.h"
#import "RadikoPlayer.h"
#import "RDIPMainView.h"
#import "RDIPStationClient.h"

#import "RDIPReverseGeocoder.h"

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
}

@property(nonatomic, readwrite) RDIP_RADIKOSTATUS radikoStatus;
@property(nonatomic, readonly) RadikoPlayer *radikoPlayer;

- (void)loadStations;
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
@end

@interface RDIPMainViewController(UpdateStatus) <CLLocationManagerDelegate, RDIPReverseGeocoderDelegate>
- (void)updateStatus;
@end

@interface RDIPMainViewController(Toolbar)
- (void)setToolbar:(BOOL)playing;
- (void)loadToolbarButtons;
@end

