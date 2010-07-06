//
//  RDIPLoadingViewCell.h
//  radikker
//
//  Created by saiten  on 10/04/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RDIPLoadingContentViewCell;

@interface RDIPLoadingViewCell : UITableViewCell {
	RDIPLoadingContentViewCell *loadingContentView;
}

- (void)setLoading:(BOOL)b;

@end
