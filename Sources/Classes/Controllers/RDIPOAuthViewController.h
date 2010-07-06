//
//  RDIPOAuthViewController.h
//  radikker
//
//  Created by saiten on 10/04/08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuthHttpClient.h"

@interface RDIPOAuthViewController : UIViewController <UIWebViewDelegate> {
	UIWebView *webView;
	UIActivityIndicatorView *indicatorView;

	OAuthHttpClient *activeClient;
	
	BOOL temporaryAccess;
}

@end
