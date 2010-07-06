//
//  RDIPSettingValueSelectViewController.h
//  radikker
//
//  Created by saiten on 10/04/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RDIPSettingValueSelectViewController : UITableViewController {
	NSString *title;
	NSString *keyName;
	NSArray *valueNames;
	NSArray *values;
}

@property(nonatomic, retain) NSString* title;
@property(nonatomic, retain) NSArray *valueNames, *values;

- (id)initWithKeyName:(NSString*)keyName;

@end
