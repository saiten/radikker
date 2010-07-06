//
//  RDIPStatusProfileViewCell.h
//  radikker
//
//  Created by saiten on 10/05/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDIPTwitterUser.h"
#import "RDIPProfileImageView.h"

@interface RDIPStatusProfileViewCell : UITableViewCell {
	id delegate;
	
	RDIPProfileImageView *profileImageView;
	UILabel *nameLabel;
	UILabel *screenNameLabel;
}

@property(nonatomic, assign) id delegate;

- (void)setUser:(RDIPTwitterUser*)user;

@end

@interface NSObject (RDIPStatusProfileViewCellDelegate)
- (void)statusProfileViewCellTapped:(RDIPStatusProfileViewCell*)statusProfileViewCell;
@end