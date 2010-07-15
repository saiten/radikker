//
//  RDIPAppDelegate.m
//  radikker
//
//  Created by saiten on 10/03/15.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "RDIPAppDelegate.h"
#import "StatusBarAlert.h"
#import "SimpleAlert.h"

#import "AppConfig.h"
#import "AppSetting.h"
#import "RDIPDefines.h"

#import "RDIPMainViewController.h"
#import "RDIPComposeViewController.h"

@implementation RDIPAppDelegate

@synthesize navigationController, composeViewController, mainController;

#pragma mark -
#pragma mark private methods

- (void)_setupController
{
	window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	
	mainController = [[RDIPMainViewController alloc] init];
	composeViewController = [[RDIPComposeViewController alloc] initWithText:@""];
	
	navigationController = [[UINavigationController alloc] initWithRootViewController:mainController];
	[navigationController.navigationBar setTintColor:[UIColor blackColor]];
	[navigationController.toolbar setTintColor:[UIColor darkGrayColor]];
	[navigationController setNavigationBarHidden:YES];
}

- (void)_startAudioSession
{
	NSError *error = nil;
	
	AVAudioSession *session = [AVAudioSession sharedInstance];
	[session setActive:YES error:&error];
	[session setDelegate:self];
	[session setCategory:AVAudioSessionCategoryPlayback error:&error];
}

- (void)_endAudioSession
{
	NSError *error = nil;
	[[AVAudioSession sharedInstance] setActive:NO error:&error];
}

- (id)_defaultValueForKey:(NSString*)key
{
	NSDictionary *settingValues = [[AppConfig sharedInstance] objectForKey:RDIPCONFIG_SETTINGVALUES];
	NSDictionary *namesAndValues = [settingValues objectForKey:key];
	return [namesAndValues objectForKey:RDIPCONFIG_SETTINGVALUES_DEFAULTVALUE];
}

- (void)_initSetting
{
	AppSetting *setting = [AppSetting sharedInstance];
	NSArray *settingKeys = [NSArray arrayWithObjects:RDIPSETTING_AUTOREFRESH, 
													 RDIPSETTING_INITIALLOAD, 
							                         RDIPSETTING_BUFFERSIZE, 
													 RDIPSETTING_INITIALPLAY, nil];
	for(NSString *key in settingKeys) {
		if(![setting objectForKey:key])
			[setting setObject:[self _defaultValueForKey:key] forKey:key];
	}
}

#pragma mark -
#pragma mark UIApplicationDelegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
	[self _setupController];
	[self _startAudioSession];
	
	[self _initSetting];
	
	[window addSubview:navigationController.view];
    [window makeKeyAndVisible];

	return YES;
}
 
- (void)applicationWillTerminate:(UIApplication *)application
{
	[self _endAudioSession];
}

- (void)dealloc
{
	[mainController release];
	[navigationController release];
	[composeViewController release];
    [window release];
    [super dealloc];
}

#pragma mark -
#pragma mark AVAudioSessionDelegate methods

- (void)beginInterruption
{
	RADIKOPLAYER_STATUS st = mainController.radikoPlayer.status;
	audioInterrupted == (st ==RADIKOPLAYER_STATUS_PLAY || 
						 st == RADIKOPLAYER_STATUS_CONNECT ||
						 st == RADIKOPLAYER_STATUS_DISCONNECT);

	[mainController.radikoPlayer stop];
}

- (void)endInterruption
{
	if(audioInterrupted)
		[mainController.radikoPlayer play];

	audioInterrupted = NO;
}

@end

#pragma mark -

@implementation UIViewController (RDIPApplicationAddition)

- (UINavigationController*)mainNavigationController
{
	RDIPAppDelegate *appDelegate = (RDIPAppDelegate*)[[UIApplication sharedApplication] delegate];
	return appDelegate.navigationController;
}

- (void)presentComposeViewControllerWithText:(NSString*)text force:(BOOL)force
{
	RDIPAppDelegate *appDelegate = (RDIPAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	NSString *currentText = appDelegate.composeViewController.text;
	if(force || (!currentText || [currentText isEqual:@""]))
		appDelegate.composeViewController.text = text;
	
	UINavigationController *nvc = [[[UINavigationController alloc] initWithRootViewController:appDelegate.composeViewController] autorelease];
	nvc.navigationBar.barStyle = UIBarStyleBlack;

	[appDelegate.navigationController statusAlertSafelyPresentModalViewController:nvc animated:YES];
}

@end

