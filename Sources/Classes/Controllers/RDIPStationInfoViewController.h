//
//  RDIPStationInfoViewController.h
//  radikker
//
//  Created by saiten on 10/04/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDIPStation.h"
#import "RDIPProgram.h"
#import "RDIPSubViewController.h"
#import "RDIPSquareButton.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface RDIPStationInfoViewController : UITableViewController <MFMailComposeViewControllerDelegate> {
	RDIPStation *station;
	RDIPProgram *program;
	
	UIActivityIndicatorView *indicatorView;
	
	NSTimer *updateTimer;
}

- (id)initWithStation:(RDIPStation*)station;

@end
