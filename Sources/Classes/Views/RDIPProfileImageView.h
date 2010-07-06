//
//  RDIPProfileImageView.h
//  radikker
//
//  Created by saiten on 10/05/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RDIPProfileImageView : UIView
{
	NSString *profileImageURL;
	UIImage *profileImage;
	BOOL checkNotify;
	CGFloat round;
}

@property(nonatomic, readwrite) CGFloat round;
- (void)setProfileImageURL:(NSString*)url;

@end


