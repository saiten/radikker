//
//  RDIPNoServiceViewController.h
//  radikker
//
//  Created by saiten on 10/07/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDIPStation.h"
#import "RDIPSubViewController.h"

@interface RDIPNoServiceViewController : RDIPSubViewController {
	NSString *title;
	NSString *message;
}

- (id)initWithTitle:(NSString *)title message:(NSString*)message;
@end
