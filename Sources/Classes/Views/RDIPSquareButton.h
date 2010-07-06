//
//  RDIPSquareButton.h
//  radikker
//
//  Created by saiten on 10/04/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RDIPSquareButton : UIControl {
	NSString *title;
	CGSize titleSize;
	UIImage *image;

	UIColor *mainColor;
	UIColor *shadowColor;
	CGSize shadowSize;
	
	NSString *badge;
}

- (id)initWithTitle:(NSString*)title;
- (id)initWithImage:(UIImage*)image;

@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) UIImage *image;
@property(nonatomic, retain) NSString *badge;

@end
