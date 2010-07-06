//
//  RDIPWebBrowserController.h
//  radikker
//
//  Created by saiten on 10/04/26.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface RDIPWebBrowserController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
	UIWebView *webView;
	UIActivityIndicatorView *indicatorView;
	NSString *currentUrl;
	
	UIBarButtonItem *backButton;
	UIBarButtonItem *forwardButton;
	UIBarButtonItem *reloadButton;
	UIBarButtonItem *cancelButton;
	UIBarButtonItem *jumpButton;
	UIBarButtonItem *spaceItem;
}

@property(nonatomic, readonly) NSString *currentUrl;

- (void)openURL:(NSString*)url;

@end


