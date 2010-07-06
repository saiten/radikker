//
//  RDIPTunerView.h
//  radikker
//
//  Created by saiten on 10/03/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDIPStation.h"
#import "RDIPTunerStationView.h"

@class RDIPTunerView;

@protocol RDIPTunerViewDelegate
- (NSInteger)numberOfStationsInTunerView:(RDIPTunerView*)tunerView;
- (RDIPStation*)tunerView:(RDIPTunerView*)tunerView stationForItemAtIndex:(NSInteger)index;
@optional
- (void)tunerView:(RDIPTunerView*)tunerView didSelectStationForItemAtIndex:(NSInteger)index;
- (void)tunerView:(RDIPTunerView*)tunerView didTuneStationForItemAtIndex:(NSInteger)index;
@end

@interface RDIPTunerView : UIView <UIScrollViewDelegate> {
	id delegate;

	UIView *contentView;
	UIScrollView *scrollView;
	NSMutableArray *stationViews;
	
	CALayer *needleLayer;
	CALayer *meterLayer;
	
	UIActivityIndicatorView *indicatorView;
	
	CGRect beforeRect;

	CGFloat beforeOffsetX;
	CGFloat isDecelerate;
	
	NSInteger selectedIndex;
	NSInteger tunedIndex;
}

@property(nonatomic, assign) id delegate;
@property(nonatomic, readwrite) NSInteger tunedIndex, selectedIndex;

@property(nonatomic, readwrite) BOOL loading;

- (void)reloadView;

@end
