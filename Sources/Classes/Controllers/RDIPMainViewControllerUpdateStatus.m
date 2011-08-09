//
//  RDIPMainViewControllerUpdateStatus.m
//  radikker
//
//  Created by saiten on 10/07/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPMainViewController.h"

#import "RDIPDefines.h"

#import "AppConfig.h"
#import "SimpleAlert.h"
#import "Reachability.h"
#import "RegexKitLite.h"

@interface RDIPMainViewController (UpdateStatusPrivate)
- (void)checkLocation;
- (void)noCheckLocation;
@end

@implementation RDIPMainViewController(UpdateStatus)

#pragma mark -
#pragma mark Check Location

- (void)reachabilityChanged:(id)object
{
	[self stopRadiko];
	[stations removeAllObjects];
	[self updateStatus];
}

- (void)updateStatus
{
	radikoStatus = RDIP_RADIKOSTATUS_CANPLAY;
	
	// check jailbreak
	if(RDIP_CHECK_JAILBREAK && 
	   [[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"]) {
		radikoStatus = RDIP_RADIKOSTATUS_NOTSUPPORTDEVICE;
	}
	
	// check location via 3G
	if(RDIP_CHECK_LOCATION_VIA_3G && radikoStatus == RDIP_RADIKOSTATUS_CANPLAY) {
		Reachability *r = [Reachability reachabilityForInternetConnection];
		NetworkStatus st = [r currentReachabilityStatus];
		if(st == ReachableViaWWAN) {
			radikoStatus = RDIP_RADIKOSTATUS_CHECKLOCATION;
			NSNumber *first = [[AppSetting sharedInstance] objectForKey:RDIPSETTING_FIRSTCONNECTVIA3G];
			if(![first boolValue]) {
				[[SimpleAlert sharedInstance] confirmTitle:NSLocalizedString(@"Confirm", @"confirm")
                                           message:NSLocalizedString(@"It is necessary to confirm your location to use radikker via 3G.", 
                                                                     @"first_connect_via_3g_message")
                                            target:self 
                                       allowAction:@selector(checkLocation)
                                        denyAction:@selector(noCheckLocation)];
			} else {
				[self checkLocation];
			}
		}
	}
  
	[self loadStations];
}

- (void)checkLocation
{
	[[AppSetting sharedInstance] setObject:[NSNumber numberWithBool:YES] 												
									forKey:RDIPSETTING_FIRSTCONNECTVIA3G];
	
	CLLocationManager *locationManager = [[CLLocationManager alloc] init];
	if([locationManager locationServicesEnabled]) {
		locationManager.delegate = self;
		locationManager.distanceFilter = kCLDistanceFilterNone;
		locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		[locationManager startUpdatingLocation];
	}	
}

- (void)noCheckLocation
{
	radikoStatus = RDIP_RADIKOSTATUS_NOTSERVICESAREA;
	[self loadStations];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	CLLocationCoordinate2D coordinate = newLocation.coordinate;
	RDIPReverseGeocoder *reverseGeocoder = [[RDIPReverseGeocoder alloc] initWithCoordinate:coordinate];
	reverseGeocoder.delegate = self;
	[reverseGeocoder start];
	
	[manager autorelease];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	SimpleAlertShow(@"Location Error", [error localizedDescription]);
	
	radikoStatus = RDIP_RADIKOSTATUS_NOTSERVICESAREA;	
	[self loadStations];
	
	[manager autorelease];
}

#pragma mark -
#pragma mark MKReverseGeocoderDelegate methods

- (void)reverseGeocoder:(RDIPReverseGeocoder *)geocoder didFindAddresses:(NSDictionary *)addresses
{
	RDIP_RADIKOSTATUS status = RDIP_RADIKOSTATUS_NOTSERVICESAREA;	
	
	NSArray *results = [addresses objectForKey:@"results"];
	if(results && results.count > 0) {
		
		NSString *formatted_address = nil;
		for(NSDictionary *result in results) {
			NSString *s = [result objectForKey:@"formatted_address"];
			if(formatted_address == nil || formatted_address.length < s.length)
				formatted_address = s;
		}

#ifdef DEBUG
		NSLog(@"fomratted_address : %@", formatted_address);
#endif
		
		NSArray *allowPrefecture = [[AppConfig sharedInstance] objectForKey:@"AllowPrefecture"];
		
		for(NSString *prefecture in allowPrefecture) {
			if([formatted_address isMatchedByRegex:prefecture]) {
				status = RDIP_RADIKOSTATUS_CANPLAY;
				break;
			}
		}
	}
	
	radikoStatus = status;
  [self loadStations];
	[geocoder autorelease];
}

- (void)reverseGeocoder:(RDIPReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
	SimpleAlertShow(@"Reverse Geocoding Error", [error localizedDescription]);
	
	radikoStatus = RDIP_RADIKOSTATUS_NOTSERVICESAREA;	
	[self loadStations];
	
	[geocoder autorelease];
}

@end
