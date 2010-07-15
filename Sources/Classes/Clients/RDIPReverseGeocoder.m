//
//  RDIPReverseGeocoder.m
//  radikker
//
//  Created by saiten on 10/07/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPReverseGeocoder.h"
#import "SBJSON.h"

@implementation RDIPReverseGeocoder

@synthesize delegate, addresses;

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate
{
	if((self = [super init])) {
		coordinate = aCoordinate;
	}
	return self;
}

- (void)start
{
	if(activeClient)
		return;
	
	NSString *url = @"http://maps.google.com/maps/api/geocode/json";
	NSString *latlng = [NSString stringWithFormat:@"%f,%f", coordinate.latitude, coordinate.longitude];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:latlng, @"true", nil] 
													   forKeys:[NSArray arrayWithObjects:@"latlng", @"sensor", nil]];
	
	activeClient = [[HttpClient alloc] initWithDelegate:self];
	[activeClient get:url parameters:params];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)cancel {
	if(activeClient)
		[activeClient cancel];
	
	[activeClient autorelease];
	activeClient = nil;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


- (void)httpClientSucceeded:(HttpClient*)sender response:(NSHTTPURLResponse*)response data:(NSData*)data
{
	NSError *error = nil;
	
	NSString *jsonString = [[[NSString alloc] initWithData:data
												  encoding:NSUTF8StringEncoding] autorelease];	

	SBJSON *sbJson = [SBJSON new];
	addresses = [sbJson objectWithString:jsonString error:&error];
	
	if(error) {
		if(delegate)
			[delegate reverseGeocoder:self didFailWithError:error];		
		return;
	}
	
	[addresses retain];	

	if(delegate)
		[delegate reverseGeocoder:self didFindAddresses:addresses];	
	
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
	if(delegate)
		[delegate reverseGeocoder:self didFailWithError:error];
	
	[activeClient autorelease];
	activeClient = nil;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


@end
