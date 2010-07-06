//
//  RDIPProgramViewCell.h
//  radikker
//
//  Created by saiten on 10/04/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDIPProgram.h"

@interface RDIPProgramViewCell : UITableViewCell {
	UILabel *titleLabel;
	UILabel *performerLabel;
	UILabel *timeLabel;
}

@property(nonatomic, readonly) UILabel *titleLabel, *performerLabel, *timeLabel;

- (void)setProgram:(RDIPProgram*)program;
+ (CGFloat)cellHeightForProgram:(RDIPProgram*)program;

@end

@interface RDIPProgramDescriptionViewCell : UITableViewCell <UIWebViewDelegate>
{
	UIWebView *webView;
	id delegate;
}

@property (nonatomic, assign) id delegate;
- (void)setHTML:(NSString*)html;

@end

@interface NSObject (RDIPProgramDescriptionViewCellDelegate)
- (void)programDescriptionCell:(RDIPProgramDescriptionViewCell*)cell didTouchedURL:(NSString*)url;
@end