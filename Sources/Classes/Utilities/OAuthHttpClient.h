//
//  OAuthHttpClient.h
//  radikker
//
//  Created by saiten on 10/04/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthConsumer.h"

@interface OAuthHttpClient : NSObject {
	id delegate;

	OADataFetcher *fetcher;
	OAConsumer *consumer;
	OAToken *token;

	NSString *userAgent;
}

@property(nonatomic, assign) id delegate;
@property(nonatomic, retain) OAConsumer *consumer;
@property(nonatomic, retain) OAToken *token;
@property(nonatomic, readonly) BOOL isActive;
@property(nonatomic, retain) NSString* userAgent;

- (id)initWithConsumerToken:(NSString*)cosumerToken 
			 consumerSecret:(NSString*)consumerSecret 
				accessToken:(NSString*)accessToken 
			   accessSecret:(NSString*)accessSecret;
- (id)initWithConsumer:(OAConsumer*)consumer token:(OAToken*)token;

- (void)get:(NSString*)url parameters:(NSDictionary*)params;
- (void)post:(NSString*)url parameters:(NSDictionary*)params;
- (void)cancel;

@end

@interface NSObject (OAuthHttpClientDelegate)
- (void)oAuthHttpClientSucceeded:(OAuthHttpClient*)sender ticket:(OAServiceTicket*)ticket data:(NSData*)data;
- (void)oAuthHttpClientFailed:(OAuthHttpClient*)sender error:(NSError*)error;
@end
