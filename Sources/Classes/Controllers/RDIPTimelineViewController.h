//
//  RDIPTimelineViewController.h
//  radikker
//
//  Created by saiten on 10/04/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDIPTwitterClient.h"

@interface RDIPTimelineViewController : UITableViewController {
	NSArray *statuses;

	RDIPTwitterClient *activeClient;
	NSDate *lastUpdate;

	UIView *loadingView;
	UIActivityIndicatorView *moreLoadingIndicatorView;
	
	NSTimer *updateTimer;
}

- (void)cancel;
- (void)loadTimelineWithParams:(NSDictionary*)params;

- (void)loadLatestTimelineForce:(BOOL)force;
- (void)loadLatestTimelineImpl;

- (void)loadTimelineBeforeStatusID:(UInt64)statusId count:(UInt32)count;

- (void)clearStatuses;

- (void)showLoadingView;
- (void)hideLoadingView;

@end
