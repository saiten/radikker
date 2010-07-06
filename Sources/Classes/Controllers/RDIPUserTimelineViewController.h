//
//  RDIPUserTimelineViewController.h
//  radikker
//
//  Created by saiten on 10/05/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDIPTimelineViewController.h"

@interface RDIPUserTimelineViewController : RDIPTimelineViewController {
	NSString *screenName;
}

@property(nonatomic, readonly) NSString *screenName;

- (id)initWithScreenName:(NSString*)screenName;

@end
