//
//  SimpleAlert.m
//  radikker
//
//  Created by saiten on 10/04/26.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SimpleAlert.h"

SimpleAlert *_instance = nil;

@implementation SimpleAlert

- (id)init
{
	if(self = [super init]) {
		isShow = NO;
		target = nil;
		selectors = nil;
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

+ (SimpleAlert*)sharedInstance
{
	if(_instance == nil) {
		_instance = [[SimpleAlert alloc] init];
	}
	return _instance;
}

- (void)alertTitle:(NSString *)title message:(NSString *)message
{
	if(isShow)
		return;

	target = nil;
	selectors = nil;
	
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title 
													 message:message
													delegate:self
										   cancelButtonTitle:@"OK"
										   otherButtonTitles:nil] autorelease];
	[alert show];
}

- (void)confirmTitle:(NSString *)title message:(NSString *)message
			  target:(id)aTarget allowAction:(SEL)aAllowAction denyAction:(SEL)aDenyAction
{
	if(isShow)
		return;
	
	target = aTarget;
	selectors = [[NSArray arrayWithObjects:[NSNumber valueWithPointer:aAllowAction], 
				                           [NSNumber valueWithPointer:aDenyAction], nil] retain];

	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title 
													 message:message
													delegate:self
										   cancelButtonTitle:nil
										   otherButtonTitles:@"Yes", @"No", nil] autorelease];
	[alert show];
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex < selectors.count) {
		SEL action = [(NSNumber*)[selectors objectAtIndex:buttonIndex] pointerValue];
		if(target && [target respondsToSelector:action])
			[target performSelector:action];
	}
	
	target = nil;
	[selectors release];
	selectors = nil;
	
	isShow = NO;
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
	isShow = NO;
}

@end


void SimpleAlertShow(NSString *title, NSString *message)
{
	[[SimpleAlert sharedInstance] alertTitle:title message:message];
}

