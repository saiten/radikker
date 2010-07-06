//
//  RDIPStationClient.m
//  radikker
//
//  Created by saiten on 10/03/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPStationClient.h"
#import "AppConfig.h"
#import "GDataXMLNodeUtil.h"

@implementation RDIPStationClient

@synthesize delegate, stations, areaCode, areaName;

- (id)initWithDelegate:(id)aDelegate
{
	if((self = [super init])) {
		delegate = aDelegate;
	}
	return self;
}

- (void)getStations
{
	if(activeClient)
		return;
	
	NSString *url = [[AppConfig sharedInstance] objectForKey:@"StationUrl"];
	
	activeClient = [[HttpClient alloc] initWithDelegate:self];
	[activeClient get:url parameters:nil];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)cancel {
	if(activeClient)
		[activeClient cancel];

	[activeClient autorelease];
	activeClient = nil;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)_parseXMLData:(NSData*)data error:(NSError**)pError
{
	GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithData:data options:0 error:pError] autorelease];
	if(*pError)
		return;
	
	GDataXMLNode *rootNode = [document rootElement];
	areaCode = [[[rootNode nodeForXPath:@"//stations/@area_id" error:pError] stringValue] retain];
	areaName = [[[rootNode nodeForXPath:@"//stations/@area_name" error:pError] stringValue] retain];
	
	if(!areaCode)
		return;
	
	NSArray *stationNodes = [rootNode nodesForXPath:@"//stations/station" error:pError];
	if(*pError)
		return;
	
	NSMutableArray *tStations = [NSMutableArray arrayWithCapacity:10];
	for(GDataXMLNode *stationNode in stationNodes) {
		RDIPStation *station = [RDIPStation stationWithGDataXMLNode:stationNode];
		if(station)
			[tStations addObject:station];
	}
	
	stations = [tStations retain];
}

- (void)httpClientSucceeded:(HttpClient*)sender response:(NSHTTPURLResponse*)response data:(NSData*)data
{
	NSError *error = nil;
	[self _parseXMLData:data error:&error];
	
	if(delegate && [delegate respondsToSelector:@selector(stationClient:didGetStations:)])
		[delegate stationClient:self didGetStations:stations];
					
	
	[activeClient autorelease];
	activeClient = nil;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (BOOL)httpClientShouldRedirect:(HttpClient*)sender request:(NSURLRequest*)request response:(NSHTTPURLResponse*)response
{
	return YES;
}

- (void)httpClientFailed:(HttpClient*)sender error:(NSError*)error
{
	if(delegate && [delegate respondsToSelector:@selector(stationClient:didFailWithError:)])
		[delegate stationClient:self didFailWithError:error];
	
	[activeClient autorelease];
	activeClient = nil;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


@end
