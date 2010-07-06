//
//  RDIPStatusDetailViewCell.h
//  radikker
//
//  Created by saiten  on 10/04/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDIPTwitterStatus.h"

@interface RDIPStatusDetailViewCell : UITableViewCell <UIWebViewDelegate> {
	id delegate;
	UIWebView *webView;
}

@property(nonatomic, assign) id delegate;

- (void)setStatus:(RDIPTwitterStatus*)status;

@end

@interface NSObject (RDIPStatusDetailViewCellDelegate)
- (void)statusDetailViewCell:(RDIPStatusDetailViewCell*)cell didTouchedURL:(NSString*)url;
- (void)statusDetailViewCell:(RDIPStatusDetailViewCell*)cell didTouchedUser:(NSString*)user;
- (void)statusDetailViewCell:(RDIPStatusDetailViewCell*)cell didTouchedHash:(NSString*)hash;
@end
