//
//  RDIPEPG.h
//  radikker
//
//  Created by saiten on 10/04/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDIPProgramClient.h"
#import "RDIPProgram.h"

#define RDIPEPG_GETPROGRAM_NOTIFICATION @"RDIPEPGGetProgramNotification"
#define RDIPEPG_KEY_ERROR               @"Error"

@interface RDIPEPG : NSObject {
	NSMutableDictionary *programs;
	NSString *areaId;
	RDIPProgramClient *activeClient;
}

@property(nonatomic, retain) NSString *areaId;
@property(nonatomic, readonly) NSArray *programs;

+ (id)sharedInstance;

- (RDIPProgram*)programForStationAtNow:(NSString*)stationId;
- (RDIPProgram*)programForStation:(NSString *)stationId atTime:(NSDate*)date;
- (NSArray*)programsForStation:(NSString*)stationId;
- (NSArray*)programsForStation:(NSString*)stationId fromDate:(NSDate*)fromDate toDate:(NSDate*)toDate;
- (NSInteger)indexAtProgram:(RDIPProgram*)program forStation:(NSString*)stationId;

@end
