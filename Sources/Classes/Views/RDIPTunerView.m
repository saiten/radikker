//
//  RDIPTunerView.m
//  radikker
//
//  Created by saiten on 10/03/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "graphics_util.h"
#import "RDIPTunerView.h"

@interface RDIPTunerView(private)
- (void)changeStationAnimated:(BOOL)animated;
@end

@interface RDIPTunerMeterLayer : CALayer
@end

@implementation RDIPTunerMeterLayer

- (void)drawInContext:(CGContextRef)context
{
	CGRect rect = self.bounds;
	
	CGContextSetLineWidth(context, 1.0f);
	[[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.8] set];

	for(int x = rect.origin.x; x < rect.origin.x + rect.size.width; x+=4) {
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, (CGFloat)x - .5, 0.0);
		CGContextAddLineToPoint(context, (CGFloat)x - .5, x % 12 == 4 ? 10.0 : 6.0);
		CGContextStrokePath(context);
	}
}

@end

@interface RDIPTunerNeedleLayer : CALayer
@end

@implementation RDIPTunerNeedleLayer
- (void)createPath:(CGContextRef)context
{
	CGRect r = self.bounds;
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 0, 0);
	CGContextAddLineToPoint(context, r.size.width/2, r.size.height);
	CGContextAddLineToPoint(context, r.size.width, 0);
	CGContextAddLineToPoint(context, 0, 0);
	CGContextClosePath(context);
}

- (void)drawInContext:(CGContextRef)context
{
	//[self createPath:context];
	//CGContextClip(context);

	CGContextSimpleGradationDraw(context, self.bounds, 
								 [UIColor colorWithRed:0.45 green:0.1 blue:0.1 alpha:0.9].CGColor,
								 [UIColor colorWithRed:0.65 green:0.15 blue:0.15 alpha:0.8].CGColor);
	
	[[UIColor colorWithRed:0.85 green:0.2 blue:0.2 alpha:0.6] set];
	CGContextStrokeRect(context, self.bounds);
}

@end

@implementation RDIPTunerView

@synthesize delegate;

- (void)createViews
{
	self.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
	
	contentView = [[UIView alloc] initWithFrame:CGRectZero];
	contentView.backgroundColor = [UIColor clearColor];
	stationViews = [[NSMutableArray array] retain];
	
	meterLayer = [[RDIPTunerMeterLayer layer] retain];
	meterLayer.frame = CGRectMake(0, 0, 640.0, 12.0);
	[meterLayer setNeedsDisplay];

	meterLayer.zPosition = 1.5f;
	[contentView.layer addSublayer:meterLayer];

	needleLayer = [[RDIPTunerNeedleLayer layer] retain];
	needleLayer.frame = CGRectMake(0, 0, 6.0, 20.0);
	[needleLayer setNeedsDisplay];

	needleLayer.zPosition = 2.0f;
	needleLayer.opacity = 0.0f;
	[contentView.layer addSublayer:needleLayer];

	scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
	[scrollView setCanCancelContentTouches:NO];
	scrollView.bounces = YES;
	scrollView.scrollEnabled = YES;
	scrollView.pagingEnabled = NO;
	scrollView.contentSize = CGSizeZero;
	scrollView.contentOffset = CGPointZero;
	scrollView.showsHorizontalScrollIndicator = NO;
	scrollView.showsVerticalScrollIndicator = NO;
	scrollView.delegate = self;
	scrollView.scrollsToTop = NO;
	[scrollView addSubview:contentView];
	
	indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	indicatorView.hidesWhenStopped = YES;
	
	[self addSubview:scrollView];
	[self addSubview:indicatorView];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self createViews];
    }
    return self;
}

- (void)layoutContentView
{
	contentView.transform = CGAffineTransformIdentity;
	
	CGRect rect = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height);
	if(stationViews.count == 0) {
		contentView.frame = rect;
		return;
	}

	CGFloat halfWidth = rect.size.width/2;

	CGSize stationSize = CGSizeMake(120, 64);
	CGFloat vMargin = (rect.size.height - stationSize.height) / 2;
	
	for(int index=0; index<stationViews.count; index++) {
		RDIPTunerStationView *v = [stationViews objectAtIndex:index];
		CGRect stationRect = CGRectMake((halfWidth * (index+1)) - (stationSize.width/2), vMargin,
										stationSize.width, stationSize.height);
		v.frame = stationRect;
	}

	contentView.bounds = CGRectMake(0, 0, rect.size.width * stationViews.count, rect.size.height);
	contentView.frame = contentView.bounds;	
	scrollView.contentSize = CGSizeMake(contentView.frame.size.width, contentView.frame.size.height);
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect rect = CGRectInset(self.frame, 0, 0);
	
	if(CGRectEqualToRect(rect, beforeRect))
		return;
	
	beforeRect = self.frame;

	scrollView.frame = rect;

	indicatorView.frame = CGRectMake((rect.size.width - 24)/2, (rect.size.height - 24)/2, 24, 24);
	[self layoutContentView];
}

- (void)reloadView
{
	int	stationCount = [delegate numberOfStationsInTunerView:self];
	
	for(int index=0; index<stationCount; index++) {
		RDIPStation *station = [delegate tunerView:self stationForItemAtIndex:index];
		
		RDIPTunerStationView *stationView;
		if(index < stationViews.count) {
			stationView = [stationViews objectAtIndex:index];
		} else {
			stationView = [[[RDIPTunerStationView alloc] initWithFrame:CGRectZero] autorelease];
			stationView.delegate = self;
			[stationViews addObject:stationView];
		}
		stationView.station = station;
		
		[contentView addSubview:stationView];
	}
	
	for(int index = stationCount;index < stationViews.count; index++) {
		[(RDIPTunerStationView*)[stationViews objectAtIndex:index] removeFromSuperview];
		[stationViews removeObjectAtIndex:index];
	}
	
	[self layoutContentView];
}

- (NSInteger)selectedIndex
{
	return selectedIndex;
}

- (void)setSelectedIndex:(NSInteger)i animated:(BOOL)animated
{
	selectedIndex = i;
	[self changeStationAnimated:animated];
	if(delegate && [delegate respondsToSelector:@selector(tunerView:didSelectStationForItemAtIndex:)])
		[delegate tunerView:self didSelectStationForItemAtIndex:selectedIndex];
}

- (void)setSelectedIndex:(NSInteger)i
{
    [self setSelectedIndex:i animated:NO];
}

- (NSInteger)tunedIndex
{
	return tunedIndex;
}

- (void)setTunedIndex:(NSInteger)i
{
	NSInteger oldIndex = tunedIndex;
	if(oldIndex >= stationViews.count)
		oldIndex = stationViews.count - 1;

	tunedIndex = i;

	if(tunedIndex < 0) {
		needleLayer.opacity = 0.0;
	} else {
		needleLayer.opacity = 1.0;
	}

	// animation
	CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position"];
	anim.fillMode = kCAFillModeForwards;
	anim.duration = 0.5f;
	anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

	CGRect from = [(UIView*)[stationViews objectAtIndex:oldIndex] frame];
	from.origin.x += from.size.width / 2;
	from.origin.y = needleLayer.frame.size.height / 2;
	anim.fromValue = [NSValue valueWithCGPoint:from.origin];

	CGRect to = [(UIView*)[stationViews objectAtIndex:tunedIndex] frame];
	to.origin.x += to.size.width / 2;
	to.origin.y = needleLayer.frame.size.height / 2;	
	anim.toValue = [NSValue valueWithCGPoint:to.origin];
	anim.delegate = self;
	
	[needleLayer addAnimation:anim forKey:@"TunedAnimation"];
	//needleLayer.position = to.origin;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	CABasicAnimation *anim = (CABasicAnimation*)theAnimation;
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	needleLayer.position = [anim.toValue CGPointValue];
	[CATransaction commit];
}

- (BOOL)loading
{
	return [indicatorView isAnimating];
}

- (void)setLoading:(BOOL)b
{
	if(b)
		[indicatorView startAnimating];
	else
		[indicatorView stopAnimating];

}

- (void)dealloc {
	[contentView release];
	[stationViews release];

	[meterLayer release];
	[needleLayer release];
	
	[scrollView release];
	
	[indicatorView release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark PageControl Event Methods

- (void)changeStationAnimated:(BOOL)animated
{
	CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * selectedIndex;  
    frame.origin.y = 0;  
    [scrollView scrollRectToVisible:frame animated:animated];

	CGFloat contentOffset = scrollView.contentOffset.x;
	CGAffineTransform transform = CGAffineTransformMakeTranslation(contentOffset/2, 0);
	contentView.transform = transform;
}

#pragma mark -
#pragma mark UIScrollViewDelegate methods

- (void)fittingPageScroll
{
	CGFloat contentOffset = scrollView.contentOffset.x;
	CGAffineTransform transform = CGAffineTransformMakeTranslation(contentOffset/2, 0);
	contentView.transform = transform;

	CGFloat mod = contentView.frame.origin.x - 12 * (int)(contentView.frame.origin.x / 12.0);
	CGPoint pos = CGPointMake(contentView.frame.origin.x + 160 - mod, meterLayer.frame.size.height/2);
	//NSLog(@"offset : %.2f, mod : %.2f, pos.x : %.2f", contentView.frame.origin.x, mod, pos.x);
	
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	meterLayer.position = pos;
	[CATransaction commit];
}

- (void)scrollViewDidScroll:(UIScrollView *)sv
{
	[self fittingPageScroll];
	selectedIndex = floor((sv.contentOffset.x - sv.frame.size.width / 2) / sv.frame.size.width) + 1;

	CGFloat velocity = sv.contentOffset.x - beforeOffsetX;
	if(fabs(velocity) < 10.0f && isDecelerate) {
		CGFloat sx = sv.contentOffset.x - (selectedIndex * sv.frame.size.width);
		//NSLog(@"contentOffset : %.1f, sx : %.1f, velocity : %.1f index : %d", 
		//	  sv.contentOffset.x, sx, velocity, selectedIndex);
		if(velocity >= 0) {	
			if(sx > 0 && selectedIndex < stationViews.count)
				selectedIndex++;
		} else {
			if(sx < 0 && selectedIndex > 0)
				selectedIndex--;
		}

		[self changeStationAnimated:YES];
		isDecelerate = NO;
	}
	
	beforeOffsetX = sv.contentOffset.x;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sv
{
	if(delegate && [delegate respondsToSelector:@selector(tunerView:didSelectStationForItemAtIndex:)])
		[delegate tunerView:self didSelectStationForItemAtIndex:selectedIndex];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if(decelerate) {
		isDecelerate = YES;
	} else {
		[self changeStationAnimated:YES];
	}
}

#pragma mark -
#pragma mark RDIPTunerStationViewDelegate methods

- (void)tunerStationViewDoubleTapped:(RDIPTunerStationView*)tunerStationView
{
	NSInteger index = 0;
	for(; index < stationViews.count; index++) {
		RDIPTunerStationView *v = [stationViews objectAtIndex:index];
		if(tunerStationView == v)
			break;
	}
	RDIPStation *station = [delegate tunerView:self stationForItemAtIndex:index];
	if(!station.tuning || index != selectedIndex)
		return;

	for(RDIPTunerStationView *v in stationViews) {
		if(tunerStationView != v)
			v.selected = NO;
	}

	tunerStationView.selected = YES;
	self.tunedIndex = index;
	
	if(delegate && [delegate respondsToSelector:@selector(tunerView:didTuneStationForItemAtIndex:)])
		[delegate tunerView:self didTuneStationForItemAtIndex:index];					
}

/*
- (BOOL)accessibilityScroll:(UIAccessibilityScrollDirection)direction
{
    if(direction == UIAccessibilityScrollDirectionLeft && self.tunedIndex > 0)
        return YES;
    if(direction == UIAccessibilityScrollDirectionRight && self.tunedIndex < stationViews.count)
        return YES;
    
    return NO;
}
*/

#pragma mark -
#pragma mark accessibility methods

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (UIAccessibilityTraits)accessibilityTraits
{
    return UIAccessibilityTraitAdjustable;
}

- (void)accessibilityIncrement
{
    int	stationCount = [delegate numberOfStationsInTunerView:self];
    if(selectedIndex < stationCount-1)
        [self setSelectedIndex:selectedIndex+1 animated:NO];
}

- (void)accessibilityDecrement
{
    if(selectedIndex > 0)
        [self setSelectedIndex:selectedIndex-1 animated:NO];    
}

- (NSString *)accessibilityLabel
{
    return NSLocalizedString(@"Broadcasting station tuner", @"");
}

- (NSString *)accessibilityValue
{
    int	stationCount = [delegate numberOfStationsInTunerView:self];
    NSString *selectedStation = @"";
    
    if(stationCount == 0)
        return NSLocalizedString(@"Loading", @"");
    else {
        RDIPStation *station = [delegate tunerView:self stationForItemAtIndex:selectedIndex];
        return station.stationName;
    }
}

- (NSString *)accessibilityHint
{
    return NSLocalizedString(@"tunerhint", @"");
}

@end
