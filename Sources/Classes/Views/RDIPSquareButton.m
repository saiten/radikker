//
//  RDIPSquareButton.m
//  radikker
//
//  Created by saiten on 10/04/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPSquareButton.h"
#import "graphics_util.h"

#define DRAW_FONT [UIFont boldSystemFontOfSize:12]

@implementation RDIPSquareButton

@synthesize title, image, badge;

- (id)initWithTitle:(NSString *)s
{
	if((self = [super initWithFrame:CGRectZero])) {
		self.title = s;
		self.selected = NO;
	}
	return self;		
}

- (id)initWithImage:(UIImage *)i
{
	if((self = [super initWithFrame:CGRectZero])) {
		self.image = i;
		self.selected = NO;
	}
	return self;		
}

- (void)setTitle:(NSString *)s
{
	[title release];
	title = [s retain];
	titleSize = [title sizeWithFont:DRAW_FONT 
						   forWidth:320 
					  lineBreakMode:UILineBreakModeTailTruncation];

	[self setNeedsDisplay];
}

- (void)setImage:(UIImage*)i
{
	[image release];
	image = [i retain];
	[self setNeedsDisplay];
}

- (void)setBadge:(NSString*)b
{
	[badge release];
	badge = [b retain];
	[self setNeedsDisplay];
}

- (void)setSelected:(BOOL)b
{
	[super setSelected:b];

	[mainColor release];
	[shadowColor release];
	if(self.selected) {
		mainColor   = [[UIColor colorWithRed:0.30 green:0.65 blue:0.95 alpha:1.0] retain];
		shadowColor = [[UIColor colorWithRed:0.25 green:0.55 blue:0.75 alpha:0.6] retain];
		shadowSize  = CGSizeMake(0, -1);
	} else {
		mainColor   = [[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0] retain];
		shadowColor = [[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:0.6] retain];
		shadowSize  = CGSizeMake(0, -1);
	}
}

- (void)drawImageInRect:(CGRect)rect context:(CGContextRef)context
{
	CGContextFillImageMask(context, rect, image.CGImage, image.size, mainColor.CGColor, shadowColor.CGColor, shadowSize);
}

- (void)drawTitleInRect:(CGRect)rect context:(CGContextRef)context
{	
	CGRect titleRect = CGRectMake(rect.origin.x + (rect.size.width - titleSize.width)/2,
								  rect.origin.y + (rect.size.height - titleSize.height)/2, 
								  titleSize.width, titleSize.height);
	
	CGContextSaveGState(context);
	CGContextSetShadowWithColor(context, shadowSize, 1, shadowColor.CGColor);
	
	[mainColor set];
	[title drawInRect:titleRect
			 withFont:DRAW_FONT
		lineBreakMode:UILineBreakModeTailTruncation 
			alignment:UITextAlignmentCenter];
	
	CGContextRestoreGState(context);		
}

- (void)drawRect:(CGRect)rect 
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSimpleGradationDraw(context, rect, 
								 [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0].CGColor,
								 [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1.0].CGColor);

	if(self.selected) {
		CGContextSaveGState(context);

		CGFloat margin = 4;
		CGContextSetRoundedRectangle(context, margin, margin, rect.size.width-margin*2, rect.size.height-margin*2, 4.0f);
		CGContextClip(context);
		
		CGContextSimpleGradationDraw(context, rect, 
									 [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0].CGColor, 
									 [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0].CGColor);
		[[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:.1] set];
		CGContextSetRoundedRectangle(context, margin, margin, rect.size.width-margin*2, rect.size.height-margin*2, 4.0f);
		CGContextStrokePath(context);

		CGContextRestoreGState(context);
	}

	UIFont *font = [UIFont boldSystemFontOfSize:12];
	if(badge) {
		CGFloat marginx = 8.0f;
		CGSize badgeSize = [badge sizeWithFont:font forWidth:rect.size.width lineBreakMode:UILineBreakModeTailTruncation];
		CGSize itemSize = image ? image.size : titleSize;

		CGSize bodySize = CGSizeMake(itemSize.width + badgeSize.width + marginx*2, 
									 itemSize.height > badgeSize.height ? itemSize.height : badgeSize.height);
		CGPoint bodyPoint = CGPointMake((rect.size.width - bodySize.width)/2, (rect.size.height - bodySize.height)/2);

		if(image)
			[self drawImageInRect:CGRectMake(bodyPoint.x, bodyPoint.y, itemSize.width, itemSize.height) 
						  context:context];
		else
			[self drawImageInRect:CGRectMake(bodyPoint.x, bodyPoint.y, itemSize.width, itemSize.height) 
						  context:context];
		
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, bodyPoint.x + itemSize.width + marginx, bodyPoint.y + itemSize.height/2 - 6);
		CGContextAddLineToPoint(context, bodyPoint.x + itemSize.width + marginx, bodyPoint.y + itemSize.height/2 + 6);
		CGContextClosePath(context);
		
		CGContextSaveGState(context);
		CGContextSetShadowWithColor(context, shadowSize, 1, shadowColor.CGColor);

		[mainColor set];
		CGContextSetLineWidth(context, 1.0);
		CGContextStrokePath(context);
		
		[badge drawInRect:CGRectMake(bodyPoint.x + itemSize.width + marginx*2, 
									 bodyPoint.y + (itemSize.height - badgeSize.height)/2, 
									 badgeSize.width, badgeSize.height)
				 withFont:DRAW_FONT
			lineBreakMode:UILineBreakModeTailTruncation 
				alignment:UITextAlignmentCenter];
		
		CGContextRestoreGState(context);
	} else {
		if(image)
			[self drawImageInRect:rect context:context];
		else
			[self drawTitleInRect:rect context:context];
	}
	
}

- (void)dealloc 
{
	[image release];
	[title release];
    [super dealloc];
}


@end
