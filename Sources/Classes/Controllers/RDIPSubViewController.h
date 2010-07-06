//
//  RDIPSubViewController.h
//  radikker
//
//  Created by saiten on 10/04/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDIPSubView.h"

@interface RDIPSubViewController : UIViewController {
	NSArray *viewControllers;
	RDIPSubView *subView;
	NSInteger selectedIndex;
	UIViewController *currentViewController;	
}

@property(nonatomic, readwrite) NSInteger selectedIndex;

- (NSArray*)loadButtons;
- (NSArray*)loadViewControllers;

- (NSInteger)indexOfController:(UIViewController*)vc;
- (NSInteger)indexOfButton:(UIControl*)button;
- (UIView*)buttonAtIndex:(NSInteger)index;

@end

@interface UIViewController (RDIPSubViewControllerAddition)
- (RDIPSubViewController*)parentSubViewController;
- (UIView*)subViewButton;
@end