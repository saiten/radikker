//
//  RDIPProgramClient.m
//  radikker
//
//  Created by saiten on 10/04/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPProgramClient.h"
#import "AppConfig.h"
#import "GDataXMLNodeUtil.h"

@implementation RDIPProgramClient

@synthesize delegate, programs;

- (id)initWithDelegate:(id)aDelegate
{
	if((self = [super init])) {
		delegate = aDelegate;
	}
	return self;
}

- (void)_getProgramsWithMode:(NSString*)mode areaId:(NSString*)areaId
{
	if(activeClient)
		return;
	
	NSString *base_url = [[AppConfig sharedInstance] objectForKey:@"ProgramUrl"];

    NSString *url = [NSString stringWithFormat:@"%@/%@", base_url, mode];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:areaId, nil]
													   forKeys:[NSArray arrayWithObjects:@"area_id", nil]];
	
	activeClient = [[HttpClient alloc] initWithDelegate:self];
	[activeClient get:url parameters:params];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)getProgramsOnTodayWithAreaId:(NSString*)areaId
{
	[self _getProgramsWithMode:@"today" areaId:areaId];
}

- (void)getProgramsOnTomorrowWithAreaId:(NSString*)areaId
{
	[self _getProgramsWithMode:@"tomorrow" areaId:areaId];
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
	NSArray *stationNodes = [rootNode nodesForXPath:@"//stations/station" error:pError];
	if(*pError)
		return;

	NSMutableDictionary *tPrograms = [NSMutableDictionary dictionary];
	for(GDataXMLNode *stationNode in stationNodes) {

		NSString *stationId = nil;
		for(GDataXMLNode *attr in [(GDataXMLElement*)stationNode attributes]) {
			if([[attr name] isEqualToString:@"id"]) {
				stationId = [attr stringValue];
				break;
			}
		}
		
		if(stationId == nil)
			continue;
		
		NSArray *progArr = [stationNode nodesForXPath:@"scd/progs/prog" error:pError];
		if(*pError)
			continue;
		
		NSMutableArray *arr = [NSMutableArray array];
		for(GDataXMLNode *childNode in progArr) {
			RDIPProgram *program = [RDIPProgram programWithGdataXMLNode:childNode];
			if(program)
				[arr addObject:program];
		}

		[arr sortUsingSelector:@selector(compareDate:)];
		
		if(arr)
			[tPrograms setObject:arr forKey:stationId];
	}

	programs = [tPrograms retain];
}

- (void)httpClientSucceeded:(HttpClient*)sender response:(NSHTTPURLResponse*)response data:(NSData*)data
{
	NSError *error = nil;
	[self _parseXMLData:data error:&error];
	
	if(delegate && [delegate respondsToSelector:@selector(programClient:didGetPrograms:)])
		[delegate programClient:self didGetPrograms:programs];
		
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
	if(delegate && [delegate respondsToSelector:@selector(programClient:didFailWithError:)])
		[delegate programClient:self didFailWithError:error];
	
	[activeClient autorelease];
	activeClient = nil;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


@end
