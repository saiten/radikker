//
//  RDIPStationTimelineViewController.h
//  radikker
//
//  Created by saiten on 10/04/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDIPSearchTimelineViewController.h"

@interface RDIPStationTimelineViewController : RDIPSearchTimelineViewController {
	NSString *hashTag;
}

- (id)initWithHashTag:(NSString*)hashTag;

@property(nonatomic, readonly) NSString *hashTag;

@end
