//
//  RDIPMainViewController.h
//  radikker
//
//  Created by saiten on 10/03/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppSetting.h"

#import "RDIPDefines.h"
#import "RadikoPlayer.h"
#import "RDIPMainView.h"
#import "RDIPStationClient.h"

typedef enum {
	RDIP_RADIKOSTATUS_CANPLAY,
	RDIP_RADIKOSTATUS_CHECKLOCATION,
	RDIP_RADIKOSTATUS_NOTSERVICESAREA,
	RDIP_RADIKOSTATUS_NOTSUPPORTDEVICE
} RDIP_RADIKOSTATUS;

@interface RDIPMainViewController : UIViewController <RDIPTunerViewDelegate> {
	RDIPMainView *mainView;

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
}

@property(nonatomic, readwrite) RDIP_RADIKOSTATUS radikoStatus;

- (void)playRadiko;
- (void)stopRadiko;
- (BOOL)isPlayRadiko;

- (void)loadStations;

@end
