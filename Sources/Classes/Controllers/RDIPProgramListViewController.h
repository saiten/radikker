//
//  RDIPProgramListViewController.h
//  radikker
//
//  Created by saiten on 10/05/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDIPStation.h"
#import "RDIPProgram.h"
#import "RDIPSubViewController.h"

@interface RDIPProgramListViewController : UITableViewController {
	RDIPStation *station;

	RDIPProgram *nowOnAir;
	NSArray *programs;

	NSTimer *updateTimer;

	UIActivityIndicatorView *indicatorView;
}

- (id)initWithStation:(RDIPStation*)station;

@end
