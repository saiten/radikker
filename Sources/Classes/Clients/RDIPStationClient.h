//
//  RDIPStationClient.h
//  radikker
//
//  Created by saiten on 10/03/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDIPStation.h"
#import "HttpClient.h"

@interface RDIPStationClient : NSObject {
	id delegate;
	
	NSString *areaCode;
	NSString *areaName;
	NSArray *stations;
	
	HttpClient *activeClient;
}

@property(nonatomic, assign) id delegate;
@property(nonatomic, readonly) NSString *areaCode, *areaName;
@property(nonatomic, readonly) NSArray *stations;

- (id)initWithDelegate:(id)delegate;
- (void)getStations;
- (void)cancel;

@end

@interface NSObject(RDIPStationClientDelegate)
- (void)stationClient:(RDIPStationClient*)stationClient didGetStations:(NSArray*)stations;
- (void)stationClient:(RDIPStationClient*)stationClient didFailWithError:(NSError*)error;
@end