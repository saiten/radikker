//
//  RDIPProfileImageView.m
//  radikker
//
//  Created by saiten on 10/05/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPProfileImageView.h"
#import "SharedImageStore.h"
#import "graphics_util.h"

@implementation RDIPProfileImageView

@synthesize round;

- (id)initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		checkNotify = NO;
		round = 4.0f;
	}
	return self;
}

- (void)setNotify
{
	if(!checkNotify) {
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(SharedImageStoreGetNewImageNotification:) 
													 name:SHAREDIMAGESTORE_GETNEWIMAGE_NOTIFICATION 
												   object:nil];
		checkNotify = YES;
	}
}

- (void)removeNotify
{
	if(checkNotify) {
		[[NSNotificationCenter defaultCenter] removeObserver:self 
														name:SHAREDIMAGESTORE_GETNEWIMAGE_NOTIFICATION 
													  object:nil];
		checkNotify = NO;
	}
}

- (void)setProfileImageURL:(NSString *)url
{
	[profileImageURL release];
	profileImageURL = [url retain];
	
	UIImage *image = [[SharedImageStore sharedInstance] getImage:profileImageURL];
	[profileImage release];
	profileImage = nil;

	if(image)
		profileImage = [image retain];
	else
		[self setNotify];

	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGRect drawRect = CGRectInset(rect, 1, 1);
	
	if(profileImage)
		CGContextDrawRoundedImage(context, drawRect, round, profileImage.CGImage);
	else {
		UIColor *top = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
		UIColor *bottom = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];

		CGContextSetRoundedRect(context, drawRect, round);
		CGContextClip(context);
		CGContextSimpleGradationDraw(context, drawRect, top.CGColor, bottom.CGColor);
	}
}

- (void)SharedImageStoreGetNewImageNotification:(NSNotification*)notifiation
{
	NSString *requestUrl = [[notifiation userInfo] objectForKey:SHAREDIMAGESTORE_KEY_REQUESTURL];
	if([requestUrl isEqualToString:profileImageURL]) {
		[profileImage release];
		profileImage = [[SharedImageStore sharedInstance] getImage:requestUrl];
		[profileImage retain];
		[self removeNotify];
		[self setNeedsDisplay];
	}
}

- (void)dealloc
{
	[self removeNotify];
	
	[profileImageURL release];
	[profileImage release];	
	[super dealloc];
}

@end
