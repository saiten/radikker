//
//  RDIPStatusViewCell.h
//  radikker
//
//  Created by saiten on 10/04/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDIPTwitterStatus.h"

@class RDIPStatusContentView;

@interface RDIPStatusViewCell : UITableViewCell {
	RDIPStatusContentView *statusContentView;
}

+ (CGFloat)cellHeightForStatus:(RDIPTwitterStatus*)status;
- (void)setStatus:(RDIPTwitterStatus*)status;

@end
