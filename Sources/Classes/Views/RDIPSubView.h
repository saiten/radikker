//
//  RDIPSubView.h
//  radikker
//
//  Created by saiten on 10/04/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface RDIPSubView : UIView {
	NSArray *switchButtons;
	UIView *containerView;
	
	CAGradientLayer *containerShadowLayer;
}

@property(nonatomic, retain) NSArray *switchButtons;
@property(nonatomic, retain) UIView *containerView;

@end
