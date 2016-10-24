//
//  RDIPStatusBar.m
//  radikker
//
//  Created by saiten on 10/04/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "StatusBarAlert.h"
#import <QuartzCore/QuartzCore.h>

static StatusBarAlert *_instance = nil;

@implementation StatusBarAlert

+ (id)sharedInstance
{
	if(_instance == nil) {
		_instance = [[StatusBarAlert alloc] init];
	}
	return _instance;
}

- (id)init
{
	if(self = [super init]) {
		statusLayer = [[CALayer layer] retain];
		statusLayer.delegate = self;
		statusLayer.bounds = CGRectMake(0, 0, 320, 40);
		statusLayer.backgroundColor = [UIColor colorWithRed:0.1 green:1.0 blue:0.0 alpha:1.0].CGColor;
		message = @"('A`) ...";
	}
	return self;
}


- (UIColor*)backgroundColor 
{
	return [UIColor colorWithCGColor:statusLayer.backgroundColor];
}

- (void)setBackgroundColor:(UIColor *)color
{
	statusLayer.backgroundColor = color.CGColor;
}

- (BOOL)isShow
{
	return statusLayer.superlayer != nil;
}

- (void)showStatus:(NSString*)status animated:(BOOL)animated
{
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
	
	UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];

	if(status) {
		[message release];
		message = [status retain];
		[statusLayer setNeedsDisplay];
	}

	if(statusLayer.superlayer)
		return;

	if(animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
	}

	CGRect frame = keyWindow.frame;
	frame.origin.y = 20;
	keyWindow.frame = frame;

	if(animated) {
		[UIView commitAnimations];
	}		

	if(animated) {
		CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
		anim.duration = 1.0f;
		anim.fromValue = [NSNumber numberWithFloat:0.4];
		anim.toValue = [NSNumber numberWithFloat:0.9];
		anim.autoreverses = YES;
		anim.repeatCount = HUGE_VALF;	
		[statusLayer addAnimation:anim forKey:@"RDIPStatusBar Animation"];
	}

	statusLayer.frame = CGRectMake(0, -20, 320, 40);

	[keyWindow.layer addSublayer:statusLayer];
}

- (void)hideStatusAnimated:(BOOL)animated
{
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
	UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];

	[statusLayer removeFromSuperlayer];

	if(animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
	}
	
	CGRect frame = keyWindow.frame;
	frame.origin.y = 0;
	keyWindow.frame = frame;
	
	if(animated) {
		[UIView commitAnimations];
	}
}

- (void)dealloc
{
	[statusLayer release];
	[message release];
	[super dealloc];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
	UIGraphicsPushContext(context);
	
	CGContextSetShadow(context, CGSizeMake(0, 1), 1.0);
	
	[[UIColor whiteColor] set];
	[message drawInRect:CGRectMake(0, 20, 320, 20) 
			   withFont:[UIFont boldSystemFontOfSize:14]
		  lineBreakMode:UILineBreakModeTailTruncation
			  alignment:UITextAlignmentCenter];
	
	UIGraphicsPopContext();
}

@end

@implementation UIViewController (StatusBarAlertAddition)

- (void)statusAlertSafelyPresentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated
{
	StatusBarAlert *alert = [StatusBarAlert sharedInstance];
	BOOL isShow = [alert isShow];
	if(isShow) {
		[alert hideStatusAnimated:NO];
		[self presentModalViewController:modalViewController animated:animated];
		[alert showStatus:nil animated:NO];
	} else {
		[self presentModalViewController:modalViewController animated:animated];
	}
}

- (void)statusAlertSafelyDismissModalViewControllerAnimated:(BOOL)animated
{
	StatusBarAlert *alert = [StatusBarAlert sharedInstance];
	BOOL isShow = [alert isShow];
	if(isShow) {
		[alert hideStatusAnimated:NO];
		[self dismissModalViewControllerAnimated:animated];
		[alert showStatus:nil animated:NO];
	} else {
		[self dismissModalViewControllerAnimated:animated];
	}	
}

@end

