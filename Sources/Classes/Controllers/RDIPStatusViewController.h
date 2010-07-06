//
//  RDIPStatusViewController.h
//  radikker
//
//  Created by saiten on 10/05/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDIPTwitterStatus.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class RDIPStatusProfileViewCell, RDIPStatusFooterView, RDIPStatusDetailViewCell;

@interface RDIPStatusViewController : UITableViewController <MFMailComposeViewControllerDelegate> {
	RDIPTwitterStatus *status;
	
	RDIPStatusProfileViewCell *profileCell;
	RDIPStatusDetailViewCell *statusCell;
	RDIPStatusFooterView *footerView;
}

- (id)initWithStatus:(RDIPTwitterStatus*)status;

@end
