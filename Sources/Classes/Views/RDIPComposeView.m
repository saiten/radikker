//
//  RDIPComposeView.m
//  radikker
//
//  Created by saiten on 10/04/21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPComposeView.h"


@implementation RDIPComposeView

@synthesize delegate;

- (void)createViews
{
	self.backgroundColor = [UIColor blackColor];
	
	textView = [[UITextView alloc] initWithFrame:CGRectZero];
	textView.font = [UIFont systemFontOfSize:16];
	textView.textColor = [UIColor darkTextColor];
	textView.editable = YES;
	textView.delegate = self;
	textView.backgroundColor = [UIColor whiteColor];
	
	countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 20)];
	countLabel.font = [UIFont boldSystemFontOfSize:16];
	countLabel.textColor = [UIColor whiteColor];
	countLabel.backgroundColor = [UIColor clearColor];
	countLabel.textAlignment = UITextAlignmentRight;
	countLabel.text = @"140";

	UIBarButtonItem *flexibleItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																				   target:nil
																				   action:nil] autorelease];
	UIBarButtonItem *clearButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
																				 target:self 
																				  action:@selector(pressTrashButton:)] autorelease];
	UIBarButtonItem *countItem = [[[UIBarButtonItem alloc] initWithCustomView:countLabel] autorelease];
	
	toolBar = [[UIToolbar alloc] initWithFrame:CGRectZero];
	toolBar.tintColor = [UIColor grayColor];
	toolBar.items = [NSArray arrayWithObjects:clearButton, flexibleItem, countItem, nil];
	
	overlayView = [[UIView alloc] initWithFrame:CGRectZero];
	overlayView.backgroundColor = [UIColor blackColor];
	overlayView.alpha = 0.5;
	
	indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	indicatorView.hidesWhenStopped = YES;	
	[overlayView addSubview:indicatorView];
	
	[self addSubview:textView];
	[self addSubview:toolBar];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self createViews];
    }
    return self;
}

- (void)layoutSubviews
{
	CGRect rect = CGRectInset(self.frame, 0, 0);
	
	CGRect textRect = rect;
	textRect.size.height = 168;
	textView.frame = textRect;
	
	CGRect barRect = rect;
	barRect.origin.y = 168;
	barRect.size.height = 32;
	toolBar.frame = barRect;
}

- (void)dealloc {
	[countLabel release];
	[textView release];
	
	[indicatorView release];
	[overlayView release];

    [super dealloc];
}

#pragma mark -
#pragma mark property methods

- (NSString*)text
{
	return textView.text;
}

- (void)setText:(NSString *)s
{
	textView.text = s;
}

#pragma mark -
#pragma mark original methods

- (void)showOverlay
{
	CGRect rect = [UIScreen mainScreen].applicationFrame;
	rect.origin.y += 44;
	rect.size.height -= 44;
	overlayView.frame = rect;
	
	CGRect indicatorRect = CGRectMake((rect.size.width - 24)/2, 
									  (textView.frame.size.height - 24)/2, 24, 24);
	indicatorView.frame = indicatorRect;
	[indicatorView startAnimating];

	UIWindow *w = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
	[w addSubview:overlayView];
}

- (void)hideOverlay
{
	[overlayView removeFromSuperview];
	[indicatorView stopAnimating];
}

- (void)showKeyboard
{
	[textView becomeFirstResponder];
}

- (void)updateCount
{
	NSInteger count = 140 - textView.text.length;
	
	countLabel.text = [NSString stringWithFormat:@"%d", count];
	if(count >= 0)
		countLabel.textColor = [UIColor whiteColor];
	else
		countLabel.textColor = [UIColor colorWithRed:1.0 green:0.5 blue:0.6 alpha:1.0];
}

- (void)pressTrashButton:(id)sender
{
	[self setText:@""];
}

#pragma mark -
#pragma mark UITextViewDelegate methods

- (void)textViewDidChange:(UITextView *)aTextView
{
	[self updateCount];
	if(delegate && [delegate respondsToSelector:@selector(composeViewDidChange:)])
		[delegate composeViewDidChange:self];
}

@end
