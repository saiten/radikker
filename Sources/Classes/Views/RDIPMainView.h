//
//  RDIPMainView.h
//  radikker
//
//  Created by saiten on 10/03/31.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

#import "RDIPTunerView.h"
#import "RDIPFooterView.h"

@interface RDIPMainView : UIView {
	RDIPTunerView *tunerView;
	UIView *meterView;
	UIView *containerView;
	RDIPFooterView *footerView;
    GADBannerView *bannerView;
	
	UIView *volumeBar;
	
	CAGradientLayer *navigationBarShadowLayer;
	CAGradientLayer *footerShadowLayer;
}

@property(nonatomic, readonly) RDIPTunerView *tunerView;
@property(nonatomic, readonly) GADBannerView *bannerView;
@property(nonatomic, readonly) RDIPFooterView *footerView;
@property(nonatomic, retain) UIView *containerView;

- (BOOL)isShowVolumebar;
- (void)showVolumebar;
- (void)hideVolumebar;


@end
