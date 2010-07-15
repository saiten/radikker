//
//  RDIPComposeViewController.h
//  radikker
//
//  Created by saiten on 10/04/21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDIPComposeView.h"
#import "RDIPTwitterClient.h"
#import "RDIPTwitterStatus.h"

@interface RDIPComposeViewController : UIViewController {
	RDIPTwitterStatus *postStatus;
	
	NSRange selectRange;
	NSString *text;
	RDIPComposeView *composeView;
	
	RDIPTwitterClient *activeClient;
	
	UIBarButtonItem *closeButton;
	UIBarButtonItem *cancelButton;
	UIBarButtonItem *postButton;
}

@property (nonatomic, readonly) RDIPTwitterStatus *postStatus;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, readwrite) NSRange selectRange;

- (id)initWithText:(NSString *)text;

@end
