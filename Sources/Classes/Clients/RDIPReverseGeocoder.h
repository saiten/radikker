//
//  RDIPReverseGeocoder.h
//  radikker
//
//  Created by saiten on 10/07/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "HttpClient.h"

@class RDIPReverseGeocoder;

@protocol RDIPReverseGeocoderDelegate
- (void)reverseGeocoder:(RDIPReverseGeocoder*)geocoder didFindAddresses:(NSDictionary*)addresses;
- (void)reverseGeocoder:(RDIPReverseGeocoder*)geocoder didFailWithError:(NSError*)error;
@end

@interface RDIPReverseGeocoder : NSObject {
	id<RDIPReverseGeocoderDelegate> delegate;

	CLLocationCoordinate2D coordinate;
	NSDictionary *addresses;
	
	HttpClient *activeClient;
}

@property(nonatomic, assign) id<RDIPReverseGeocoderDelegate> delegate;
@property(nonatomic, readonly) NSDictionary *addresses;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)start;
- (void)cancel;

@end
