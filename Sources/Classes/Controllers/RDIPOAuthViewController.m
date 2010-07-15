//
//  RDIPOAuthViewController.m
//  radikker
//
//  Created by saiten on 10/04/08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OAuthConsumer.h"
#import "RDIPDefines.h"
#import "twitter_apikey.h"
#import "AppSetting.h"
#import "StatusBarAlert.h"
#import "SimpleAlert.h"

#import "NSString+RDIPExtend.h"

#import "RDIPOAuthViewController.h"

@interface RDIPOAuthViewController(private)
- (void)cancel;
- (void)closeModalView:(id)sender;
- (void)requestAccessToken;
@end

@implementation RDIPOAuthViewController

- (id)init
{
	if(self = [super init]) {
	}
	return self;
}

- (void)loadView {
	webView = [[UIWebView alloc] initWithFrame:CGRectZero];
	webView.backgroundColor = [UIColor whiteColor];
	webView.delegate = self;
	webView.scalesPageToFit = YES;
	webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	webView.autoresizesSubviews = YES;
	
	indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	indicatorView.hidesWhenStopped = YES;

	self.view = webView;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																						   target:self
																						   action:@selector(closeModalView:)] autorelease];	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:indicatorView] autorelease];
	self.navigationItem.title = NSLocalizedString(@"Twitter Login", @"oauth_title");
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
}

- (void)dealloc 
{
	[self cancel];
	
	[webView release];
	[indicatorView release];
    [super dealloc];
}

#pragma mark -
#pragma mark lifecycle

- (void)viewDidAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self requestAccessToken];
	[indicatorView startAnimating];
}

- (void)viewWillDisappear:(BOOL)animated 
{
	[super viewWillDisappear:animated];
	[webView stopLoading];
	[self cancel];
}

#pragma mark -
#pragma mark original methods

- (void)cancel
{
	if(activeClient)
		[activeClient cancel];

	[activeClient autorelease];
	activeClient = nil;
}

- (void)closeModalView:(id)sender
{
	[self statusAlertSafelyDismissModalViewControllerAnimated:YES];
}

- (void)requestAccessToken
{
	[self cancel];
	
	OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:CONSUMER_KEY 
													   secret:CONSUMER_SECRET_KEY] autorelease];

	activeClient = [[OAuthHttpClient alloc] initWithConsumer:consumer token:nil];
	activeClient.delegate = self;

	temporaryAccess = YES;
	[activeClient get:@"http://twitter.com/oauth/request_token" parameters:nil];
}

- (void)oAuthHttpClientSucceeded:(OAuthHttpClient*)sender ticket:(OAServiceTicket*)ticket data:(NSData*)data
{
	if(!ticket.didSucceed) {
		SimpleAlertShow(@"Error", @"failed get AccessToken.");
		return;
	}
	
	NSString *response = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	
	OAToken *accessToken = [[OAToken alloc] initWithHTTPResponseBody:response];
	NSArray *pairs = [response componentsSeparatedByString:@"&"];
	
	for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
		if([[elements objectAtIndex:0] isEqualToString:@"user_id"]) {
			NSString *userId = [elements objectAtIndex:1];
			[[AppSetting sharedInstance] setString:userId
											forKey:RDIPSETTING_USERID];
		} else if([[elements objectAtIndex:0] isEqualToString:@"screen_name"]) {
			NSString *screenName = [elements objectAtIndex:1];
			[[AppSetting sharedInstance] setString:screenName
											forKey:RDIPSETTING_SCREENNAME];
		}
	}		
	
	if(!temporaryAccess) {
		// save AccessToken and SecretKey
		[[AppSetting sharedInstance] setString:accessToken.key 
										forKey:RDIPSETTING_ACCESSTOKEN];
		[[AppSetting sharedInstance] setString:accessToken.secret
										forKey:RDIPSETTING_SECRETKEY];
		[self closeModalView:nil];
	} else {
		// goto Authorized URL
		NSString *urlStr = [NSString stringWithFormat:@"http://twitter.com/oauth/authorize?oauth_token=%@", accessToken.key];
		NSURL *url = [NSURL URLWithString:urlStr];
		[webView loadRequest:[NSURLRequest requestWithURL:url]];
	}

	[self cancel];
}

- (void)oAuthHttpClientFailed:(OAuthHttpClient*)sender error:(NSError*)error
{
	[self cancel];	
	SimpleAlertShow(@"Error", [error localizedDescription]);
}

#pragma mark -
#pragma mark UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)req navigationType:(UIWebViewNavigationType)navigationType
{
    NSMutableURLRequest *request = (NSMutableURLRequest *)req;
	
	if([[request.URL host] isEqualToString:CALLBACK_URL_HOST]) {

		NSString *query = [request.URL query];
		NSDictionary *params = [query parseURLParameters];
		if([params objectForKey:@"oauth_token"]) {
			[self cancel];			
			OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:CONSUMER_KEY 
															 secret:CONSUMER_SECRET_KEY] autorelease];
			OAToken *token = [[[OAToken alloc] initWithHTTPResponseBody:query] autorelease];
			
			activeClient = [[OAuthHttpClient alloc] initWithConsumer:consumer token:token];
			activeClient.delegate = self;
			
			temporaryAccess = NO;
			[activeClient get:@"http://twitter.com/oauth/access_token" parameters:nil];
		} else {
			SimpleAlertShow(@"Error", @"Callback Error.");
			[indicatorView stopAnimating];
		}
		
		return NO;
	}
	
	[indicatorView startAnimating];
	
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
	[indicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	if([error code] != -999)
		SimpleAlertShow(@"Error", [error localizedDescription]);
	
	[indicatorView stopAnimating];
}

@end
