//
//  RDIPStatusViewCell.m
//  radikker
//
//  Created by saiten on 10/04/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSString+RDIPExtend.h"
#import "graphics_util.h"
#import "SharedImageStore.h"
#import "NSDate+RDIPExtend.h"

#import "RDIPStatusViewCell.h"
#import "RDIPProfileImageView.h"

#define TEXT_FONT [UIFont systemFontOfSize:14]
#define NAME_FONT [UIFont boldSystemFontOfSize:12]
#define TIME_FONT [UIFont systemFontOfSize:11]

@interface RDIPStatusContentView : UIView
{
	BOOL selected;
	RDIPTwitterStatus *status;
	RDIPProfileImageView *imageView;
}

@property(nonatomic, readwrite)BOOL selected;
- (void)setStatus:(RDIPTwitterStatus*)status;

@end

@implementation RDIPStatusContentView

@synthesize selected;

- (id)initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		selected = NO;

		imageView = [[RDIPProfileImageView alloc] initWithFrame:CGRectZero];
		[self addSubview:imageView];
	}
	return self;
}

+ (CGFloat)cellHeightForStatus:(RDIPTwitterStatus*)status
{
	NSString *unescapedText = [status.text stringByReplacingUnescapeHTML];

	CGFloat height = 0.0;
	CGSize textSize = [unescapedText sizeWithFont:TEXT_FONT
								constrainedToSize:CGSizeMake(264, 3000)
									lineBreakMode:UILineBreakModeWordWrap];
	height += textSize.height;
	height += 28;

	if(height < 48.0)
		height = 48.0;
	
	return height;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect imageRect = CGRectMake(6, 4, 40, 40);
	imageView.frame = imageRect;
}

- (void)drawRect:(CGRect)rect
{
	//CGContextRef context = UIGraphicsGetCurrentContext();

	NSString *unescapedText = [status.text stringByReplacingUnescapeHTML];
	
	CGSize textSize = [unescapedText sizeWithFont:TEXT_FONT
							  constrainedToSize:CGSizeMake(264, 3000)
								  lineBreakMode:UILineBreakModeWordWrap];
	
	if(selected)
		[[UIColor whiteColor] set];
	else
		[[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0] set];
	
	[unescapedText drawInRect:CGRectMake(52, 4, textSize.width, textSize.height)
					 withFont:TEXT_FONT 
				lineBreakMode:UILineBreakModeWordWrap
					alignment:UITextAlignmentLeft];

	CGFloat height = 28.0;
	if(textSize.height > 28.0)
		height = textSize.height + 8;
	
	if(selected)
		[[UIColor whiteColor] set];
	else
		[[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0] set];
	
	[status.user.screenName drawInRect:CGRectMake(52, height, 130, 12)
							  withFont:NAME_FONT 
						 lineBreakMode:UILineBreakModeTailTruncation
							 alignment:UITextAlignmentLeft];
	
	NSString *created = [status stringCreatedSinceNow];
	[created drawInRect:CGRectMake(180, height, 130, 12)
			   withFont:TIME_FONT 
		  lineBreakMode:UILineBreakModeTailTruncation
			  alignment:UITextAlignmentRight];
}

- (void)setStatus:(RDIPTwitterStatus*)aStatus
{
	[status release];
	status = [aStatus retain];

	[imageView setProfileImageURL:status.user.imageUrl];	
	[self setNeedsDisplay];
}

- (void)dealloc
{
	[status release];
	[imageView release];
	[super dealloc];
}

@end

@implementation RDIPStatusViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		statusContentView = [[RDIPStatusContentView alloc] initWithFrame:self.contentView.frame];
		[self.contentView addSubview:statusContentView];
    }
    return self;
}

- (void)setStatus:(RDIPTwitterStatus *)status
{
	statusContentView.selected = self.selected;
	[statusContentView setStatus:status];
}

- (void)setHighlighted:(BOOL)b animated:(BOOL)animated
{
	[super setHighlighted:b animated:animated];
	statusContentView.selected = b;
	[statusContentView setNeedsDisplay];
}

- (void)setSelected:(BOOL)b animated:(BOOL)animated
{
	[super setSelected:b animated:animated];
	statusContentView.selected = b;
	[statusContentView setNeedsDisplay];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	statusContentView.frame = self.contentView.frame;
}

+ (CGFloat)cellHeightForStatus:(RDIPTwitterStatus*)status
{
	return [RDIPStatusContentView cellHeightForStatus:status];
}

- (void)dealloc
{
	[statusContentView release];
	[super dealloc];
}

@end
