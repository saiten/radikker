//
//  RDIPStatusFooterView.m
//  radikker
//
//  Created by saiten on 10/05/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPStatusFooterView.h"

@implementation RDIPStatusFooterView

@synthesize delegate;

- (void)createViews
{
	replyButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	[replyButton setTitle:@"Reply" forState:UIControlStateNormal];
	[replyButton addTarget:self action:@selector(pressedButton:) forControlEvents:UIControlEventTouchUpInside];

	retweetButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	[retweetButton setTitle:@"Retweet" forState:UIControlStateNormal];
	[retweetButton addTarget:self action:@selector(pressedButton:) forControlEvents:UIControlEventTouchUpInside];
	
	favoriteButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	[favoriteButton setTitle:@"Favorite" forState:UIControlStateNormal];
	[favoriteButton setTitle:@"Remove Fav" forState:UIControlStateSelected];
	[favoriteButton addTarget:self action:@selector(pressedButton:) forControlEvents:UIControlEventTouchUpInside];

	[self addSubview:replyButton];
	[self addSubview:retweetButton];
	//[self addSubview:favoriteButton];
}

- (id)initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame:frame]) {
		[self createViews];
	}
	return self;
}

- (void)setStatus:(RDIPTwitterStatus *)status
{
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect rect = CGRectInset(self.frame, 0, 0);

	CGFloat margin = 8.0f;
	CGFloat width = (rect.size.width - margin*3) / 2;
	CGFloat height = 44.0f;

	CGFloat x = margin;
	CGFloat y = (rect.size.height - height) / 2;

	replyButton.frame = CGRectMake(x, y, width, height);
	x += margin + width;
	retweetButton.frame = CGRectMake(x, y, width, height);
	x += margin + width;
	//favoriteButton.frame = CGRectMake(x, y, width, height);
}

- (void)pressedButton:(id)sender
{
	if(sender == replyButton) {
		if(delegate && [delegate respondsToSelector:@selector(statusFooterViewDidTouchedReplyButton)])
			[delegate statusFooterViewDidTouchedReplyButton];
	} else if(sender == retweetButton) {
		if(delegate && [delegate respondsToSelector:@selector(statusFooterViewDidTouchedRetweetButton)])
			[delegate statusFooterViewDidTouchedRetweetButton];
	}
}

- (void)dealloc {
	[replyButton release];
	[retweetButton release];
	[favoriteButton release];
	
    [super dealloc];
}

@end
