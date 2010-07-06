//
//  RDIPProgram.h
//  radikker
//
//  Created by saiten on 10/04/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GDataXMLNode;

@interface RDIPProgram : NSObject {
	NSString  *title;
	NSDate    *fromTime;
	NSDate    *toTime;
	NSInteger  duration;
	NSString  *performer;
	NSString  *description;
	NSString  *info;
	NSString  *url;
}

@property(nonatomic, readonly) NSString *title, *performer, *description, *info, *url;
@property(nonatomic, readonly) NSDate *fromTime, *toTime;
@property(nonatomic, readonly) NSInteger duration;

+ (id)programWithGdataXMLNode:(GDataXMLNode*)xmlNode;
- (id)initWithGDataXMLNode:(GDataXMLNode*)xmlNode;

+ (id)emptyProgram;

@end
