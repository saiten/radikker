//
//  RDIPTwitterClient.h
//  radikker
//
//  Created by saiten on 10/04/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthHttpClient.h"

@interface RDIPTwitterClient : NSObject {
	id delegate;
	OAuthHttpClient *activeClient;
}

@property(nonatomic, assign) id delegate;

- (id)initWithDelegate:(id)delegate;
- (void)cancel;

- (void)getMentionsWithParams:(NSDictionary*)params;
- (void)getHomeTimelineWithParams:(NSDictionary*)params;
- (void)getUserTimeline:(NSString*)screenName params:(NSDictionary*)params;
- (void)getPublicTimelineWithParams:(NSDictionary*)params;

- (void)getDirectMessageWithParams:(NSDictionary*)params;

- (void)getSearchKeyword:(NSString*)keyword params:(NSDictionary*)params;

- (void)updateStatus:(NSString*)status;

@end

@interface NSObject(RDIPTwitterClientDelegate)
- (void)timelineClient:(RDIPTwitterClient*)timelineClient didGetTimeline:(NSArray*)timeline;
- (void)timelineClient:(RDIPTwitterClient*)timelineClient didFailWithError:(NSError*)error;
@end


