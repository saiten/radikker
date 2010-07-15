//
//  RDIPAppDelegate.h
//  radikker
//
//  Created by saiten on 10/03/15.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import "RDIPReverseGeocoder.h"

@class RDIPMainViewController, RDIPComposeViewController;

@interface RDIPAppDelegate : NSObject <UIApplicationDelegate, AVAudioSessionDelegate> 
{
	UINavigationController *navigationController;
	RDIPMainViewController *mainController;
	RDIPComposeViewController *composeViewController;
	
	UIWindow *window;
	BOOL audioInterrupted;
	
	UIBackgroundTaskIdentifier bgTask;
}

@property(nonatomic, readonly) UINavigationController *navigationController;
@property(nonatomic, readonly) RDIPMainViewController *mainController;
@property(nonatomic, readonly) RDIPComposeViewController *composeViewController;

@end

@interface UIViewController (RDIPApplicationAddition)
- (UINavigationController*)mainNavigationController;
- (void)presentComposeViewControllerWithText:(NSString*)text force:(BOOL)force;
@end