//
//  RDIPFooterView.m
//  radikker
//
//  Created by saiten on 10/03/31.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPFooterView.h"
#import "graphics_util.h"

@implementation RDIPFooterView

- (id)initWithFrame:(CGRect)frame
{
	if((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self setNeedsDisplay];
}

- (void)setAreaName:(NSString *)n
{
	[areaName release];
	areaName = [n retain];
	
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSimpleGradationDraw(context, rect, 
								 [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0].CGColor,
								 [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1.0].CGColor);
	
	// draw top border
	[[UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:1.0] set];
	CGContextSetLineWidth(context, 1.0);
	CGContextStrokeRect(context, CGRectMake(rect.origin.x, rect.origin.y + .5, rect.size.width, 0));
	[[UIColor whiteColor] set];
	CGContextStrokeRect(context, CGRectMake(rect.origin.x, rect.origin.y + 1.5, rect.size.width, 0));

	//draw area name
	if(areaName) {
		[[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0] set];
		UIFont *areaFont = [UIFont boldSystemFontOfSize:10];
		[[NSString stringWithFormat:@"%@", areaName] drawInRect:CGRectInset(rect, 10, 2) 
													   withFont:areaFont];
	}
}

- (void)dealloc {
	[areaName release];
	[radikoLogo release];
    [super dealloc];
}


@end
