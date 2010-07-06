//
//  RDIPStatusFooterView.h
//  radikker
//
//  Created by saiten on 10/05/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDIPTwitterStatus.h"

@interface RDIPStatusFooterView : UIView {
	id delegate;
	
	UIButton *replyButton;
	UIButton *favoriteButton;
	UIButton *retweetButton;
}

@property(nonatomic, assign) id delegate;

- (void)setStatus:(RDIPTwitterStatus*)status;

@end

@interface NSObject (RDIPStatusFooterViewDelegate)
- (void)statusFooterViewDidTouchedReplyButton;
- (void)statusFooterViewDidTouchedRetweetButton;
- (void)statusFooterViewDidTouchedFavoriteButton;
@end