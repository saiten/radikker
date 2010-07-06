//
//  RDIPStatusBar.h
//  radikker
//
//  Created by saiten on 10/04/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StatusBarAlert : NSObject
{
	CALayer *statusLayer;
	NSString *message;
}

@property (nonatomic, retain) UIColor *backgroundColor;

+(id)sharedInstance;
- (void)showStatus:(NSString*)status animated:(BOOL)animated;
- (void)hideStatusAnimated:(BOOL)animated;
- (BOOL)isShow;
@end

@interface UIViewController (StatusBarAlertAddition)
- (void)statusAlertSafelyPresentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated;
- (void)statusAlertSafelyDismissModalViewControllerAnimated:(BOOL)animated;
@end