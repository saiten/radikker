//
//  RDIPMainViewControllerTunerViewDelegate.m
//  radikker
//
//  Created by saiten on 10/07/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPMainViewController.h"
#import "RDIPStationViewController.h"
#import "RDIPTwitterViewController.h"
#import "RDIPNoServiceViewController.h"

@implementation RDIPMainViewController(TunerViewDelegate)

#pragma mark -
#pragma mark tuner control

- (void)createViewControllers
{
	NSMutableArray *removeKeys = [NSMutableArray arrayWithArray:[stationViewControllers allKeys]];
	
	for(RDIPStation *station in stations) {
		UIViewController *controller = [stationViewControllers objectForKey:station.stationId];
		if(controller) {
			[removeKeys removeObject:station.stationId];
		} else {
			if([station isKindOfClass:[RDIPTwitterStation class]]) {
				controller = [[[RDIPTwitterViewController alloc] init] autorelease];
			}else if([station isKindOfClass:[RDIPNoServiceStation class]]) {
				NSString *title = NSLocalizedString(@"No Service", @"");
				NSString *message = nil;
				if(radikoStatus == RDIP_RADIKOSTATUS_NOTSERVICESAREA)
					message = NSLocalizedString(@"Your location is not a service area.", @"");
				else if(radikoStatus == RDIP_RADIKOSTATUS_NOTSUPPORTDEVICE)
					message = NSLocalizedString(@"Your device is not supported.", @"");
				else
					message = NSLocalizedString(@"Unknown Error", @"");
				
				controller = [[[RDIPNoServiceViewController alloc] initWithTitle:title message:message] autorelease];
			} else if([station isKindOfClass:[RDIPUpdateStateStation class]]) {
				controller = [[[UIViewController alloc] init] autorelease];
			} else {
				RDIPStationViewController *stationController = [[[RDIPStationViewController alloc] initWithStation:station] autorelease];
				stationController.delegate = self;
				controller = stationController;
			}
			[stationViewControllers setValue:controller forKey:station.stationId];
		}
	}
	[stationViewControllers removeObjectsForKeys:removeKeys];	
}

- (NSArray*)stationsWithTuningItem
{
	NSMutableArray *arr = [NSMutableArray array];
	for(RDIPStation *station in stations) {
		if(station.tuning)
			[arr addObject:station];
	}
	
	if(arr.count > 0)
		return arr;
	else
		return nil;
}

- (NSArray*)stationsWithKindOfClass:(Class)class
{
	NSMutableArray *arr = [NSMutableArray array];
	for(RDIPStation *station in stations) {
		if([station isKindOfClass:class])
			[arr addObject:station];
	}
	
	if(arr.count > 0)
		return arr;
	else
		return nil;
}

- (void)setTwitterStation
{
	NSArray *arr = [self stationsWithKindOfClass:[RDIPTwitterStation class]];
	
	NSString *userId = [[AppSetting sharedInstance] objectForKey:RDIPSETTING_USERID];	
	if(userId) {
		if(!arr) {
			RDIPTwitterStation *twitterStation = [[[RDIPTwitterStation alloc] init] autorelease];
			[stations addObject:twitterStation];
		}
	} else {
		for(RDIPStation *s in arr)
			[stations removeObject:s];
	}
}

- (void)setNoServiceStation
{
	NSArray *arr = [self stationsWithKindOfClass:[RDIPNoServiceStation class]];
	
	if(radikoStatus == RDIP_RADIKOSTATUS_NOTSERVICESAREA ||
		radikoStatus == RDIP_RADIKOSTATUS_NOTSUPPORTDEVICE) {
		if(!arr) {
			RDIPNoServiceStation *noServiceStation = [[[RDIPNoServiceStation alloc] init] autorelease];
			[stations insertObject:noServiceStation atIndex:0];
		}
	} else {
		for(RDIPStation *s in arr)
			[stations removeObject:s];
	}
}

- (void)setUpdateStateStation
{
	NSArray *arr = [self stationsWithKindOfClass:[RDIPUpdateStateStation class]];
	
	if(radikoStatus == RDIP_RADIKOSTATUS_CHECKLOCATION ||
	   (radikoStatus == RDIP_RADIKOSTATUS_CANPLAY && ![self stationsWithTuningItem])) {
		if(!arr) {
			RDIPUpdateStateStation *updateStateStation = [[[RDIPUpdateStateStation alloc] init] autorelease];
			[stations insertObject:updateStateStation atIndex:0];
		}
	} else {
		for(RDIPStation *s in arr)
			[stations removeObject:s];
	}
}

- (void)unavailableTuner
{
	mainView.tunerView.loading = NO;
    refreshButton.enabled = YES;
    
	radikoStatus = RDIP_RADIKOSTATUS_NOTSERVICESAREA;
	[self reloadTuner];
}

- (void)reloadTuner
{
	[self setUpdateStateStation];
	[self setNoServiceStation];
	[self setTwitterStation];
	
	[self createViewControllers];
	
	//mainView.tunerView.loading = NO;
	[mainView.tunerView reloadView];
	
	playButton.enabled = (radikoStatus == RDIP_RADIKOSTATUS_CANPLAY);
	
	if(selectedStationIndex >= stations.count)
		selectedStationIndex = stations.count-1;
	
	if(tunedStationIndex >= stations.count)
		tunedStationIndex = stations.count-1;	
	
	if(stations.count > 0) {
		mainView.tunerView.selectedIndex = selectedStationIndex;
		mainView.tunerView.tunedIndex = tunedStationIndex;
		[self tunerView:nil didSelectStationForItemAtIndex:selectedStationIndex];
	}
}

#pragma mark -
#pragma mark TunerViewDelegate method

- (NSInteger)numberOfStationsInTunerView:(RDIPTunerView *)tunerView
{
	return stations.count;
}

- (RDIPStation*)tunerView:(RDIPTunerView *)tunerView stationForItemAtIndex:(NSInteger)index
{
	return [stations objectAtIndex:index];
}

- (void)tunerView:(RDIPTunerView *)tunerView didSelectStationForItemAtIndex:(NSInteger)index
{
	BOOL animated = NO;
	selectedStationIndex = index;
    
	RDIPStation *selectStation = [stations objectAtIndex:index];
    if ([selectStation isMemberOfClass:[RDIPStation class]]) {
        RDIPProgram *program = [[RDIPEPG sharedInstance] programForStationAtNow:selectStation.stationId];
        if(program) {
            [self updateAdWithURLString:program.url];
        }
    }

	UIViewController *newController = [stationViewControllers objectForKey:selectStation.stationId];
	
	if(newController && currentViewController != newController) {
		UIViewController *oldController = currentViewController;
		currentViewController = [newController retain];
		
		[oldController viewWillDisappear:animated];
		[newController viewWillAppear:animated];
		
		mainView.containerView = newController.view;
		
		[oldController viewDidDisappear:animated];
		[newController viewDidAppear:animated];
		
		[oldController release];
	}
}

- (void)tunerView:(RDIPTunerView *)tunerView didTuneStationForItemAtIndex:(NSInteger)index
{
	tunedStationIndex = index;
	[self playRadiko];
}

#pragma mark -
#pragma mark RDIPStationViewControllerDelegate methods

- (BOOL)stationViewController:(RDIPStationViewController*)viewController nowOnAirAtStation:(RDIPStation*)station
{
	if(!(radikoPlayer.status == RADIKOPLAYER_STATUS_CONNECT || radikoPlayer.status == RADIKOPLAYER_STATUS_PLAY))
		return NO;
	
	if([radikoPlayer.channel isEqualToString:station.stationId])
		return YES;
	else 
		return NO;
}

@end
