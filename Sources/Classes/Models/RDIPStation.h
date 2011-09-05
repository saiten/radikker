//
//  RDIPStation.h
//  radikker
//
//  Created by saiten on 10/03/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GDataXMLNode;

@interface RDIPStation : NSObject {
	NSString *stationId;
	NSString *stationName;
	NSString *logoUrl;
	NSString *feedUrl;
	NSString *bannerUrl;
	BOOL tuning;
}

@property(nonatomic, readonly) NSString *stationId, *stationName, *logoUrl, *feedUrl, *bannerUrl;
@property(nonatomic, readonly) BOOL tuning;

- (id)initWithGDataXMLNode:(GDataXMLNode*)xmlNode;
+ (id)stationWithGDataXMLNode:(GDataXMLNode*)xmlNode;

@end

@interface RDIPTwitterStation : RDIPStation {
}
@end

@interface RDIPNoServiceStation : RDIPStation {
}
@end

@interface RDIPUpdateStateStation : RDIPStation {
}
@end

@interface RDIPRadiruStation : RDIPStation {
}
- (id)initWithChannel:(NSString*)channel;
@end

