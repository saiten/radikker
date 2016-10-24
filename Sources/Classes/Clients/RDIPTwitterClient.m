//
//  RDIPTwitterClient.m
//  radikker
//
//  Created by saiten on 10/04/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPTwitterClient.h"
#import "RDIPDefines.h"
#import "environment.h"
#import "AppSetting.h"
#import "SBJSON.h"

#import "RDIPTwitterStatus.h"

@implementation RDIPTwitterClient

@synthesize delegate;

- (id)initWithDelegate:(id)aDelegate
{
	if(self = [super init]) {
		delegate = aDelegate;
	}
	return self;
}

- (void)postRequest:(NSString*)url parameters:(NSDictionary*)params
{
	[self cancel];

	activeClient = [[OAuthHttpClient alloc] initWithConsumerToken:CONSUMER_KEY 
												   consumerSecret:CONSUMER_SECRET_KEY
													  accessToken:[[AppSetting sharedInstance] stringForKey:RDIPSETTING_ACCESSTOKEN]
													 accessSecret:[[AppSetting sharedInstance] stringForKey:RDIPSETTING_SECRETKEY]];
	activeClient.delegate = self;
	
	[activeClient post:url parameters:params];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];	
}

- (void)getRequest:(NSString*)url parameters:(NSDictionary*)params
{
	[self cancel];
	
	activeClient = [[OAuthHttpClient alloc] initWithConsumerToken:CONSUMER_KEY 
												   consumerSecret:CONSUMER_SECRET_KEY
													  accessToken:[[AppSetting sharedInstance] stringForKey:RDIPSETTING_ACCESSTOKEN]
													 accessSecret:[[AppSetting sharedInstance] stringForKey:RDIPSETTING_SECRETKEY]];
	activeClient.delegate = self;
	
	[activeClient get:url parameters:params];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)getStatuses:(NSString*)statusType format:(NSString*)format params:(NSDictionary*)params
{
	NSString *url = [NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/%@.%@", statusType, format];
	[self getRequest:url parameters:params];
}

- (void)postStatuses:(NSString*)statusType format:(NSString*)format params:(NSDictionary*)params
{
	NSString *url = [NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/%@.%@", statusType, format];
	[self postRequest:url parameters:params];
}


- (void)getDirectMessageFormat:(NSString*)format params:(NSDictionary*)params
{
	NSString *url = [NSString stringWithFormat:@"https://api.twitter.com/1.1/direct_messages.%@", format];
	[self getRequest:url parameters:params];
}

- (void)getSearchFormat:(NSString*)format params:(NSDictionary*)params
{
	NSString *url = [NSString stringWithFormat:@"https://api.twitter.com/1.1/search/tweets.%@", format];
	[self getRequest:url parameters:params];
}

- (void)getMentionsWithParams:(NSDictionary*)params;
{
	[self getStatuses:@"mentions_timeline" format:@"json" params:params];
}

- (void)getHomeTimelineWithParams:(NSDictionary*)params;
{
	[self getStatuses:@"home_timeline" format:@"json" params:params];
}

- (void)getUserTimeline:(NSString*)screenName params:(NSDictionary*)params
{
	NSMutableDictionary *p = [NSMutableDictionary dictionaryWithDictionary:params];
	[p setObject:screenName forKey:@"screen_name"];

	[self getStatuses:@"user_timeline" format:@"json" params:p];
}

- (void)getPublicTimelineWithParams:(NSDictionary*)params;
{
	[self getStatuses:@"public_timeline" format:@"json" params:params];
}

- (void)getDirectMessageWithParams:(NSDictionary*)params
{
	[self getDirectMessageFormat:@"json" params:params];
}

- (void)getSearchKeyword:(NSString*)keyword params:(NSDictionary*)params
{
	NSMutableDictionary *qParams = [NSMutableDictionary dictionaryWithDictionary:params];
	[qParams setObject:keyword forKey:@"q"];
    [qParams setObject:@"recent" forKey:@"result_type"];
	
	[self getSearchFormat:@"json" params:qParams];
}

- (void)updateStatus:(NSString*)status
{
	NSDictionary *dic = [NSDictionary dictionaryWithObject:status forKey:@"status"];
	[self postStatuses:@"update" format:@"json" params:dic];
}

- (void)cancel
{
	if(activeClient)
		[activeClient cancel];
	
	[activeClient autorelease];
	activeClient = nil;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)oAuthHttpClientSucceeded:(OAuthHttpClient*)sender ticket:(OAServiceTicket*)ticket data:(NSData*)data
{
	[self cancel];

	NSError *error = nil;
	
	NSString *jsonString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	
	SBJSON *sbJson = [SBJSON new];

	NSArray *statusesDic = nil;
	id json = [sbJson objectWithString:jsonString error:&error];
	if([json isKindOfClass:[NSArray class]]) {  // statuses
		statusesDic = json;
	} else if([json isKindOfClass:[NSDictionary class]]) {
		if([json objectForKey:@"statuses"]) { // search
			statusesDic = [json objectForKey:@"statuses"];
		} else if([json objectForKey:@"text"]) { // status
			statusesDic = [NSArray arrayWithObject:json];
		}
	}
	
	if(error) {
		if(delegate && [delegate respondsToSelector:@selector(timelineClient:didFailWithError:)])
			[delegate timelineClient:self didFailWithError:error];
		return;
	}

	NSMutableArray *statuses = [NSMutableArray array];
	for(NSDictionary *statusDic in statusesDic) {
		RDIPTwitterStatus *status = [RDIPTwitterStatus statusWithDictionary:statusDic];
		if(status == nil)
			continue;
		[statuses addObject:status];
	}
	
	if(delegate && [delegate respondsToSelector:@selector(timelineClient:didGetTimeline:)])
		[delegate timelineClient:self didGetTimeline:statuses];	

	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)oAuthHttpClientFailed:(OAuthHttpClient*)sender error:(NSError*)error
{
	[self cancel];

	if(delegate && [delegate respondsToSelector:@selector(timelineClient:didFailWithError:)])
		[delegate timelineClient:self didFailWithError:error];		

	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


@end
