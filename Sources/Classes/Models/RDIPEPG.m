//
//  RDIPEPG.m
//  radikker
//
//  Created by saiten on 10/04/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPEPG.h"

static RDIPEPG *_instance = nil;

@implementation RDIPEPG

@synthesize areaId;

+ (id)sharedInstance
{
	if(_instance == nil) {
		_instance = [[RDIPEPG alloc] init];
	}
	return _instance;
}

- (id)init
{
	if(self = [super init]) {
		programs = [[NSMutableDictionary dictionary] retain];
	}
	return self;
}

- (void)dealloc
{
	[activeClient release];
	[programs release];
	[areaId release];
	
	[super dealloc];
}

- (NSArray*)programs { 
	return (NSArray*)programs; 
}

- (void)getPrograms:(NSDate*)date
{
	@synchronized(activeClient) {
		if(activeClient == nil) {
			activeClient = [[RDIPProgramClient alloc] initWithDelegate:self];
			[activeClient getProgramsOnTodayWithAreaId:areaId];			
		}
	}
}

- (RDIPProgram*)programForStation:(NSString *)stationId atTime:(NSDate*)date
{
	if(programs.count > 0) {
		NSArray *arr = [programs objectForKey:stationId];
		for(RDIPProgram *program in arr) {
			if([program.fromTime compare:date] != NSOrderedDescending &&
			   [program.toTime compare:date] != NSOrderedAscending)
				return program;
		}
		return [RDIPProgram emptyProgram];
	} else {
		[self getPrograms:date];
	}
	return nil;
}

- (RDIPProgram*)programForStationAtNow:(NSString *)stationId
{
	return [self programForStation:stationId atTime:[NSDate date]];
}

- (NSArray*)programsForStation:(NSString*)stationId
{
	if(programs.count > 0) {
		return [programs objectForKey:stationId];
	} else {
		[self getPrograms:[NSDate date]];
	}
	return nil;
}

- (void)programClient:(RDIPProgramClient*)stationClient didGetPrograms:(NSDictionary*)aPrograms
{
	[programs addEntriesFromDictionary:aPrograms];

	[[NSNotificationCenter defaultCenter] postNotificationName:RDIPEPG_GETPROGRAM_NOTIFICATION
														object:self 
													  userInfo:nil];
	[activeClient autorelease];
	activeClient = nil;
}

- (void)programClient:(RDIPProgramClient*)stationClient didFailWithError:(NSError*)error
{
	NSDictionary *userDic = [NSDictionary dictionaryWithObject:error forKey:RDIPEPG_KEY_ERROR];
	[[NSNotificationCenter defaultCenter] postNotificationName:RDIPEPG_GETPROGRAM_NOTIFICATION
														object:self 
													  userInfo:userDic];
	[activeClient autorelease];
	activeClient = nil;
}


@end
