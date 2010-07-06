//
//  RDIPStationView.h
//  radikker
//
//  Created by saiten on 10/03/31.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDIPStation.h"

typedef enum {
	STATIONVIEW_STATE_PLAY,
	STATIONVIEW_STATE_LOADING,
	STATIONVIEW_STATE_STOP,
} STATIONVIEW_STATE;

@interface RDIPTunerStationView : UIView
{
	RDIPStation *station;
	
	UIActivityIndicatorView *indicatorView;
	UIImageView *logoImageView;
	
	BOOL selected;
	STATIONVIEW_STATE state;
	
	id delegate;
}

@property(nonatomic, assign) id delegate;
@property(nonatomic, retain) RDIPStation *station;
@property(nonatomic, readwrite) BOOL selected;
@property(nonatomic, readwrite) STATIONVIEW_STATE state;

@end

@interface NSObject (RDIPTunerStationViewDelegate)
- (void)tunerStationViewDoubleTapped:(RDIPTunerStationView*)tunerStationView;
@end