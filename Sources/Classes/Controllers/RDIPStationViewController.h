//
//  RDIPStationViewController.h
//  radikker
//
//  Created by saiten on 10/04/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDIPStation.h"
#import "RDIPSubViewController.h"
#import "RDIPSquareButton.h"

@interface RDIPStationViewController : RDIPSubViewController {
	id delegate;
	
	RDIPStation *station;

	RDIPSquareButton *infoButton;
	RDIPSquareButton *listButton;
	RDIPSquareButton *tweetButton;
	
	BOOL _nowOnAir;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly) BOOL nowOnAir;

- (id)initWithStation:(RDIPStation*)station;

@end

@interface NSObject (RDIPStationViewControllerDelegate)
- (BOOL)stationViewController:(RDIPStationViewController*)viewController nowOnAirAtStation:(RDIPStation*)station;
@end

