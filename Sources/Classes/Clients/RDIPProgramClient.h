//
//  RDIPProgramClient.h
//  radikker
//
//  Created by saiten on 10/04/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDIPProgram.h"
#import "HttpClient.h"

@interface RDIPProgramClient : NSObject {
	id delegate;
	NSDictionary *programs;
	
	HttpClient *activeClient;
}

@property(nonatomic, assign) id delegate;
@property(nonatomic, readonly) NSDictionary *programs;

- (id)initWithDelegate:(id)delegate;
- (void)getProgramsOnTodayWithAreaId:(NSString*)areaId;
- (void)getProgramsOnTomorrowWithAreaId:(NSString*)areaId;
- (void)cancel;

@end

@interface NSObject(RDIPProgramClientDelegate)
- (void)programClient:(RDIPProgramClient*)stationClient didGetPrograms:(NSDictionary*)programs;
- (void)programClient:(RDIPProgramClient*)stationClient didFailWithError:(NSError*)error;
@end