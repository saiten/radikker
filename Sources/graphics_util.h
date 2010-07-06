/*
 *  graphic_util.h
 *  radikker
 *
 *  Created by saiten on 09/11/26.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __SYUN_GRAPHICS_H__
#define __SYUN_GRAPHICS_H__

#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

static inline void CGContextSetRoundedRectangle(CGContextRef context, CGFloat x, CGFloat y, CGFloat w, CGFloat h, CGFloat r)
{
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, x + w/2, y);
	CGContextAddArcToPoint(context, x + w,     y,   x + w, y + h/2, r);
	CGContextAddArcToPoint(context, x + w, y + h, x + w/2,   y + h, r);
	CGContextAddArcToPoint(context,     x, y + h,        x,y + h/2, r);
	CGContextAddArcToPoint(context,     x,     y, x + w/2,       y, r);
	CGContextClosePath(context);
}

static inline void CGContextSetRoundedRect(CGContextRef context, CGRect rect, CGFloat r)
{
	CGContextSetRoundedRectangle(context, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height, r);
}

static inline void CGContextSetVaryRoundedRectangle(CGContextRef context, CGFloat x, CGFloat y, CGFloat w, CGFloat h, 
									                CGFloat tr_r, CGFloat tl_r, CGFloat br_r, CGFloat bl_r)
{
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, x + w/2, y);
	CGContextAddArcToPoint(context, x + w,     y,   x + w, y + h/2, tl_r);
	CGContextAddArcToPoint(context, x + w, y + h, x + w/2,   y + h, bl_r);
	CGContextAddArcToPoint(context,     x, y + h,       x, y + h/2, br_r);
	CGContextAddArcToPoint(context,     x,     y, x + w/2,       y, tr_r);
	CGContextClosePath(context);
}

static inline void CGContextFillRoundedRectangle(CGContextRef context, CGFloat x, CGFloat y, CGFloat w, CGFloat h, CGFloat r)
{
	CGContextSetRoundedRectangle(context, x, y, w, h, r);
	CGContextFillPath(context);	
}

static inline void CGContextFillRoundedRect(CGContextRef context, CGRect rect, CGFloat r)
{
	CGContextSetRoundedRect(context, rect, r);
	CGContextFillPath(context);	
}

static inline void CGContextSimpleGradationDraw(CGContextRef context, CGRect frame, CGColorRef top, CGColorRef bottom)
{
	CGColorRef colorArray[2] = { top, bottom };
    CGFloat    locations[2]  = { 0.0, 1.0 };
	
	CFArrayCallBacks arrayCallBacks = kCFTypeArrayCallBacks;
	arrayCallBacks.retain = NULL;
	arrayCallBacks.release = NULL;
	
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CFArrayRef colors = CFArrayCreate(kCFAllocatorDefault, (const void**)colorArray, 2, &arrayCallBacks);
	CGGradientRef gradation = CGGradientCreateWithColors(space, colors, locations);
	
	// draw rectangle
	CGContextDrawLinearGradient(context, gradation, 
								CGPointMake(frame.size.width/2, frame.origin.y), 
								CGPointMake(frame.size.width/2, frame.size.height), 
								kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	
	CFRelease(colors);
	CGGradientRelease(gradation);
	CGColorSpaceRelease(space);
}

static inline void CGContextDrawImageInRect(CGContextRef context, CGRect rect, CGImageRef image, CGSize imageSize, CGColorRef shadowColor, CGSize shadowSize)
{
	CGRect imgRect = CGRectMake(rect.origin.x + (rect.size.width - imageSize.width)/2, 
								rect.origin.y + (rect.size.height - imageSize.height)/2, 
								imageSize.width, imageSize.height);
	
	CGContextSaveGState(context);

	if(shadowColor != NULL)
		CGContextSetShadowWithColor(context, shadowSize, 2, shadowColor);
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	transform.d = -1.0f;
	transform.ty = imgRect.origin.y + imgRect.size.height;
	imgRect.origin.y = 0;
	
	CGContextConcatCTM(context, transform);		

	CGContextDrawImage(context, imgRect, image);
	
	CGContextRestoreGState(context);		
}

static inline void CGContextDrawRoundedImage(CGContextRef context, CGRect rect, CGFloat round, CGImageRef image)
{
	CGContextSaveGState(context);
	
	CGContextSetRoundedRectangle(context, 
								 rect.origin.x, rect.origin.y,
								 rect.size.width, rect.size.height, round);
	CGContextClip(context);
	CGContextDrawImageInRect(context, rect, image, rect.size, NULL, CGSizeZero);
	
	CGContextRestoreGState(context);
}

static inline void CGContextFillImageMask(CGContextRef context, CGRect rect, CGImageRef image, CGSize imageSize, CGColorRef color, CGColorRef shadowColor, CGSize shadowSize)
{
	CGRect imgRect = CGRectMake(rect.origin.x + (rect.size.width - imageSize.width)/2, 
								rect.origin.y + (rect.size.height - imageSize.height)/2, 
								imageSize.width, imageSize.height);
	
	CGContextSaveGState(context);

	if(shadowColor != NULL)
		CGContextSetShadowWithColor(context, shadowSize, 2, shadowColor);
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	transform.d = -1.0f;
	transform.ty = imgRect.origin.y + imgRect.size.height;
	imgRect.origin.y = 0;
	
	CGContextConcatCTM(context, transform);		
	
	CGContextClipToMask(context, imgRect, image);

	CGContextSetFillColorWithColor(context, color);
	CGContextFillRect(context, imgRect);
	
	CGContextRestoreGState(context);		
}


#endif

