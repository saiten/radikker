//
//  RDIPLoadingViewCell.m
//  radikker
//
//  Created by saiten  on 10/04/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPLoadingViewCell.h"
#import "graphics_util.h"

@interface RDIPLoadingContentViewCell : UIView
{
	BOOL selected;
	BOOL isLoading;
	UIImage *refreshImage;
	UIImage *cancelImage;
}
@property(nonatomic, readwrite) BOOL selected, isLoading;
@end

@implementation RDIPLoadingContentViewCell

@synthesize isLoading, selected;

- (id)initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame:frame]) {
		refreshImage = [[UIImage imageNamed:@"refresh.png"] retain];
		cancelImage = [[UIImage imageNamed:@"cancel.png"] retain];
		self.backgroundColor = [UIColor whiteColor];
	}
	return self;
}

- (void)setSelected:(BOOL)b
{
	selected = b;
	[self setNeedsDisplay];
}

- (void)setIsLoading:(BOOL)b
{
	isLoading = b;
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
	UIFont *font = [UIFont boldSystemFontOfSize:16];
	UIColor *color = [UIColor colorWithRed:0.1 green:0.55 blue:1.0 alpha:1.0];

	if(selected)
		color = [UIColor whiteColor];
	
	CGContextRef context = UIGraphicsGetCurrentContext();

	NSString *text = nil;
	UIImage *image = nil;

	if(isLoading) {
		text = @"Cancel";
		image = cancelImage;
	} else {
		text = @"Refresh";
		image = refreshImage;
	}

	CGFloat marginx = 8.0;
	CGSize textSize = [text sizeWithFont:font];
	CGSize imageSize = CGSizeMake(20, 20);

	CGFloat contentWidth = textSize.width + imageSize.width + marginx;
	CGRect imageRect = CGRectMake(rect.origin.x + (rect.size.width - contentWidth)/2, 
								  rect.origin.y + (rect.size.height - imageSize.width)/2, 
								  imageSize.width, imageSize.height);

	CGRect textRect = CGRectMake(imageRect.origin.x + imageRect.size.width + marginx,
								 rect.origin.y + (rect.size.height - textSize.height)/2,
								 textSize.width, textSize.height);
	
	CGContextFillImageMask(context, imageRect, image.CGImage, imageSize, color.CGColor, NULL, CGSizeZero);
	[color set];
	[text drawInRect:textRect withFont:font];
}

- (void)dealloc
{
	[refreshImage release];
	[cancelImage release];
	[super dealloc];
}

@end

@implementation RDIPLoadingViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		loadingContentView = [[RDIPLoadingContentViewCell alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:loadingContentView];
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	loadingContentView.frame = self.contentView.frame;
}

- (void)setHighlighted:(BOOL)b animated:(BOOL)animated
{
	[super setHighlighted:b animated:animated];
	loadingContentView.selected = b;
	[loadingContentView setNeedsDisplay];
}

- (void)setSelected:(BOOL)b animated:(BOOL)animated
{
	[super setSelected:b animated:animated];
	loadingContentView.selected = b;
	[loadingContentView setNeedsDisplay];
}

- (void)setLoading:(BOOL)b
{
	loadingContentView.isLoading = b;
	[loadingContentView setNeedsDisplay];
}

- (void)dealloc {
	[loadingContentView release];
    [super dealloc];
}

@end
