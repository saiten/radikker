//
//  RDIPSearchTimelineViewController.h
//  radikker
//
//  Created by saiten  on 10/04/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDIPTimelineViewController.h"

@interface RDIPSearchTimelineViewController : RDIPTimelineViewController <UISearchBarDelegate> {
	NSMutableString *currentKeyword;
	UISearchBar *searchBar;
	UIControl *overlayCoverView;
}

@property(nonatomic, retain) NSString *keyword;

@end
