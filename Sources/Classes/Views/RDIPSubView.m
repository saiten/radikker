//
//  RDIPSubView.m
//  radikker
//
//  Created by saiten on 10/04/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPSubView.h"

@implementation RDIPSubView

@synthesize containerView, switchButtons;

- (void)createShadows
{
	self.backgroundColor = [UIColor clearColor];
	
	CGColorRef lightColorRef = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0].CGColor;
	CGColorRef darkColorRef  = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3].CGColor;
	NSArray *downColors = [NSArray arrayWithObjects:(id)darkColorRef, (id)lightColorRef, nil];
	
	NSNumber *one  = [NSNumber numberWithFloat:1.0f];
	NSNumber *zero = [NSNumber numberWithFloat:0.0f];
	NSArray *locations = [NSArray arrayWithObjects:zero, one, nil];
	
	containerShadowLayer = [[CAGradientLayer layer] retain];
	containerShadowLayer.colors = downColors;
	containerShadowLayer.locations = locations;
	containerShadowLayer.zPosition = 10.0f;

	[self.layer addSublayer:containerShadowLayer];
}

- (void)createViews
{
	switchButtons = nil;
	containerView = nil;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self createViews];
		[self createShadows];
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect rect = self.frame;

	CGFloat btnWidth = rect.size.width / switchButtons.count;
	for(int i=0; i<switchButtons.count; i++) {
		UIView *button = [switchButtons objectAtIndex:i];
		button.frame = CGRectMake(btnWidth * i, 0, btnWidth, 44);
	}

	containerShadowLayer.frame = CGRectMake(0, 44, rect.size.width, 10);
	containerView.frame = CGRectMake(0, 44, rect.size.width, rect.size.height - 44);
}

- (void)setSwitchButtons:(NSArray *)buttons
{
	for(UIView *view in switchButtons)
		[view removeFromSuperview];

	[switchButtons release];
	switchButtons = [buttons retain];

	for(UIView *view in switchButtons)
		[self addSubview:view];
}

- (void)setContainerView:(UIView *)v
{
	[containerView removeFromSuperview];
	[containerView release];
	
	containerView = [v retain];
	[self insertSubview:containerView atIndex:0];
}

- (void)dealloc {
	[switchButtons release];
	[containerView release];
	[containerShadowLayer release];
	
    [super dealloc];
}


@end
