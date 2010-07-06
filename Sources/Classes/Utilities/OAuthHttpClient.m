//
//  OAuthHttpClient.m
//  radikker
//
//  Created by saiten on 10/04/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OAuthHttpClient.h"
#import "StringHelper.h"

@implementation OAuthHttpClient

@synthesize delegate, consumer, token, userAgent;

- (id)initWithConsumerToken:(NSString *)consumerToken 
			 consumerSecret:(NSString *)consumerSecret
				accessToken:(NSString *)accessToken 
			   accessSecret:(NSString *)accessSecret
{
	OAConsumer *aConsumer = [[[OAConsumer alloc] initWithKey:consumerToken 
													  secret:consumerSecret] autorelease];
	OAToken *aToken = [[[OAToken alloc] initWithKey:accessToken
											 secret:accessSecret] autorelease];
	return [self initWithConsumer:aConsumer token:aToken];
}

- (id)initWithConsumer:(OAConsumer *)aConsumer token:(OAToken *)aToken
{
	if(self = [super init]) {
		consumer = [aConsumer retain];
		token = [aToken retain];
	}
	
	return self;
}

- (void)dealloc
{
	[self cancel];
	
	[fetcher release];
	[consumer release];
	[token release];

	[userAgent release];
	
	[super dealloc];
}

//
// copy from HttpClient.m
//
- (NSString*)buildParameters:(NSDictionary*)params
{
	NSMutableString* s = [NSMutableString string];
	if (params) {
		NSEnumerator* e = [params keyEnumerator];
		NSString* key;
		while (key = (NSString*)[e nextObject]) {
			NSString* value = [[params objectForKey:key] encodeAsURIComponent];
			[s appendFormat:@"%@=%@&", key, value];
		}
		if (s.length > 0) [s deleteCharactersInRange:NSMakeRange(s.length-1, 1)];
	}
	return s;
}

- (void)get:(NSString *)url parameters:(NSDictionary *)params
{
	[self cancel];

	NSMutableString* fullUrl = [NSMutableString stringWithString:url];
	NSString* paramStr = [self buildParameters:params];
	if (paramStr.length > 0) {
		[fullUrl appendString:@"?"];
		[fullUrl appendString:paramStr];
	}
	
	OAMutableURLRequest *req = [[[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:fullUrl] 
																consumer:consumer 
																   token:token
																   realm:nil 
													   signatureProvider:nil] autorelease];
	if(userAgent) 
		[req setValue:userAgent forHTTPHeaderField:@"User-Agent"];
	[req setHTTPShouldHandleCookies:YES];

	fetcher = [[OADataFetcher alloc] init];
	[fetcher fetchDataWithRequest:req 
						 delegate:self 
				didFinishSelector:@selector(requestTokenTicket:didFinishWithData:) 
				  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];

}

- (void)post:(NSString *)url parameters:(NSDictionary *)params
{
	[self cancel];

	NSData* body = [[self buildParameters:params] dataUsingEncoding:NSUTF8StringEncoding];

	OAMutableURLRequest *req = [[[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] 
																consumer:consumer 
																   token:token
																   realm:nil 
													   signatureProvider:nil] autorelease];
	[req setHTTPMethod:@"POST"];
	if(userAgent)
		[req setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [req setValue:[NSString stringWithFormat:@"%d", body.length] forHTTPHeaderField:@"Content-Length"];
	[req setHTTPBody:body];
	//[req setHTTPShouldHandleCookies:YES];

	fetcher = [[OADataFetcher alloc] init];
	[fetcher fetchDataWithRequest:req 
						 delegate:self 
				didFinishSelector:@selector(requestTokenTicket:didFinishWithData:) 
				  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];	
}

- (void)cancel
{
	if(fetcher) {
		[fetcher cancel];
		[fetcher autorelease];
	}

	fetcher = nil;
}

- (BOOL)isActive
{
	return fetcher != nil;
}

- (void)requestTokenTicket:(OAServiceTicket*)ticket didFinishWithData:(NSData*)data
{
	[self cancel];
	
	NSHTTPURLResponse *httpRes = (NSHTTPURLResponse*)ticket.response;
	if([httpRes statusCode] == 200) {	
		if(delegate && [delegate respondsToSelector:@selector(oAuthHttpClientSucceeded:ticket:data:)])
			[delegate oAuthHttpClientSucceeded:self ticket:ticket data:data];
	} else {
		NSString *message = [NSString stringWithFormat:@"%d %@", 
							 [httpRes statusCode], 
							 [NSHTTPURLResponse localizedStringForStatusCode:[httpRes statusCode]]];
		
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message
															 forKey:NSLocalizedDescriptionKey];		
		NSError *error = [[[NSError alloc] initWithDomain:@"OAuthHttoClient" code:100 userInfo:userInfo] autorelease];
		
		if(delegate && [delegate respondsToSelector:@selector(oAuthHttpClientFailed:error:)])
			[delegate oAuthHttpClientFailed:self error:error];
	}
}

- (void)requestTokenTicket:(OAServiceTicket*)ticket didFailWithError:(NSError*)error
{
	[self cancel];

	if(delegate && [delegate respondsToSelector:@selector(oAuthHttpClientFailed:error:)])
		[delegate oAuthHttpClientFailed:self error:error];
}

@end
