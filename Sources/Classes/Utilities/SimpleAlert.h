//
//  SimpleAlert.h
//  radikker
//
//  Created by saiten on 10/04/26.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimpleAlert : NSObject <UIAlertViewDelegate>
{
	BOOL isShow;
	id target;
	NSArray *selectors;
}

+ (SimpleAlert*)sharedInstance;
- (void)alertTitle:(NSString*)title message:(NSString*)message;
- (void)confirmTitle:(NSString*)title message:(NSString*)message 
			  target:(id)target allowAction:(SEL)allowAction denyAction:(SEL)denyAction;
@end

void SimpleAlertShow(NSString *title, NSString *message);
