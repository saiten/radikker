//
//  RDIPComposeView.h
//  radikker
//
//  Created by saiten on 10/04/21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RDIPComposeView : UIView <UITextViewDelegate> {
	id delegate;
	
	UIToolbar *toolBar;
	UILabel *countLabel;
	UITextView *textView;
	
	UIView *overlayView;
	UIActivityIndicatorView *indicatorView;
}

@property(nonatomic, assign) id delegate;
@property(nonatomic, retain) NSString *text;
@property(nonatomic, readwrite) NSRange selectRange;

- (void)showKeyboard;
- (void)showOverlay;
- (void)hideOverlay;

@end

@interface NSObject (RDIPComposeViewDelegate)
- (void)composeViewDidChange:(RDIPComposeView*)composeView;
@end