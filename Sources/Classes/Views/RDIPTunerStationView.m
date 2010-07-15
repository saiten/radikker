//
//  RDIPStationView.m
//  radikker
//
//  Created by saiten on 10/03/31.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPTunerStationView.h"
#import "SharedImageStore.h"
#import <QuartzCore/QuartzCore.h>

@implementation RDIPTunerStationView

@synthesize station, selected, state, delegate;

- (void)createViews
{
	self.backgroundColor = [UIColor clearColor];
	
	logoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];	
	indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	indicatorView.hidesWhenStopped = YES;
	
	[self addSubview:logoImageView];
	[self addSubview:indicatorView];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self createViews];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(SharedImageStoreGetNewImageNotification:) 
													 name:SHAREDIMAGESTORE_GETNEWIMAGE_NOTIFICATION 
												   object:nil];		
    }
    return self;
}

- (void)setStation:(RDIPStation*)aStation
{
	[station release];
	station = [aStation retain];

	UIImage *logoImage = nil;
	if(station.logoUrl)
		logoImage = [[SharedImageStore sharedInstance] getImage:station.logoUrl];

	if(logoImage) {
		[indicatorView stopAnimating];
		logoImageView.image = logoImage;
	} else {
		[indicatorView startAnimating];
		logoImageView.image = nil;
	}
	
	[self layoutSubviews];
}

- (void)layoutSubviews
{
	CGRect rect = CGRectInset(self.frame, 0, 0);
	
	CGSize imageSize = logoImageView.image.size;
	logoImageView.frame = CGRectMake((rect.size.width - imageSize.width)/2, 
									 (rect.size.height - imageSize.height)/2, 
									 imageSize.width, imageSize.height);
	indicatorView.frame = CGRectMake((rect.size.width - 24)/2, 
									 (rect.size.height - 24)/2, 
									 24, 24);
}

- (void)SharedImageStoreGetNewImageNotification:(NSNotification*)notifiation
{
	NSString *requestUrl = [[notifiation userInfo] objectForKey:SHAREDIMAGESTORE_KEY_REQUESTURL];
	if([requestUrl isEqualToString:station.logoUrl]) {
		logoImageView.image = [[SharedImageStore sharedInstance] getImage:requestUrl];
		[indicatorView stopAnimating];
		[self layoutSubviews];
	}
}

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch *touch = [touches anyObject];
	
    if([touch tapCount] == 2) {
		if(delegate && [delegate respondsToSelector:@selector(tunerStationViewDoubleTapped:)])
			[delegate tunerStationViewDoubleTapped:self];
    }
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:SHAREDIMAGESTORE_GETNEWIMAGE_NOTIFICATION 
												  object:nil];

	[station release];
	[logoImageView release];
	[indicatorView release];
	
    [super dealloc];
}

@end
