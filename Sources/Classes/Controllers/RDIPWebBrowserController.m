    //
//  RDIPWebBrowserController.m
//  radikker
//
//  Created by saiten on 10/04/26.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPWebBrowserController.h"

#import "SimpleAlert.h"
#import "StatusBarAlert.h"

@implementation RDIPWebBrowserController

@synthesize currentUrl;

- (void)loadView 
{
	webView = [[UIWebView alloc] initWithFrame:CGRectZero];
	webView.backgroundColor = [UIColor whiteColor];
	webView.delegate = self;
	webView.scalesPageToFit = YES;
	webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	webView.autoresizesSubviews = YES;
	
	self.view = webView;
	
	indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	indicatorView.hidesWhenStopped = YES;
	
	backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left.png"]
												  style:UIBarButtonItemStylePlain
												 target:self
												 action:@selector(pressBackButton:)];
	forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"right.png"]
													 style:UIBarButtonItemStylePlain
													target:self
													action:@selector(pressForwardButton:)];
	reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																 target:self 
																 action:@selector(pressReloadButton:)];
	cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
																 target:self 
																 action:@selector(pressCancelButton:)];
	jumpButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
															   target:self 
															   action:@selector(pressJumpButton:)];
	
	spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
															  target:nil
															  action:nil];	
	backButton.enabled = NO;
	forwardButton.enabled = NO;
}

- (void)setLoadingToolbar
{
	self.toolbarItems = [NSArray arrayWithObjects:
						 backButton, spaceItem, 
						 forwardButton, spaceItem,
						 cancelButton, spaceItem, 
						 jumpButton, nil];
}

- (void)setNormalToolbar
{
	self.toolbarItems = [NSArray arrayWithObjects:
						 backButton, spaceItem, 
						 forwardButton, spaceItem,
						 reloadButton, spaceItem, 
						 jumpButton, nil];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	UIBarButtonItem *indicatorItem = [[[UIBarButtonItem alloc] initWithCustomView:indicatorView] autorelease];
	self.navigationItem.rightBarButtonItem = indicatorItem;
	
	[self setNormalToolbar];
	
	if(currentUrl)
		[self openURL:currentUrl];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];

	[currentUrl release];
	currentUrl = [[[webView.request URL] absoluteString] retain];

	[webView release];
	webView = nil;
}

- (void)dealloc {
	[webView release];
	[indicatorView release];
	[currentUrl release];
	
	[backButton release];
	[forwardButton release];
	[reloadButton release];
	[cancelButton release];
	[jumpButton release];
	[spaceItem release];

    [super dealloc];
}

#pragma mark -
#pragma mark lifecycle methods

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	[self.navigationController setToolbarHidden:NO animated:YES];	
}

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated 
{
    [super viewWillDisappear:animated];
	[webView stopLoading];
}

- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark original methods

- (void)openURL:(NSString*)url
{
	NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
	[webView loadRequest:req];
}

- (void)pressBackButton:(id)sender
{
	[webView goBack];
}

- (void)pressForwardButton:(id)sender
{
	[webView goForward];
}

- (void)pressReloadButton:(id)sender
{
	[webView reload];
}

- (void)pressCancelButton:(id)sender
{
	[webView stopLoading];
}

- (void)pressJumpButton:(id)sender
{
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil 
															  delegate:self 
													 cancelButtonTitle:NSLocalizedString(@"Cancel", @"cancel")
												destructiveButtonTitle:nil
													 otherButtonTitles:NSLocalizedString(@"Open with Safari", @"open_with_safari"),
								   NSLocalizedString(@"Email this link", @"email_this_link"), nil] autorelease];
	[actionSheet showInView:self.view.window];
}

#pragma mark -
#pragma mark UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView*)aWebView
{
	self.title = @"Loading..";
	[indicatorView startAnimating];

	backButton.enabled = [webView canGoBack];
	forwardButton.enabled = [webView canGoForward];
	[self setLoadingToolbar];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
	[currentUrl release];
	currentUrl = [[[webView request] URL] absoluteString];
	[currentUrl retain];
	
	self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];

	[indicatorView stopAnimating];

	backButton.enabled = [webView canGoBack];
	forwardButton.enabled = [webView canGoForward];
	[self setNormalToolbar];
}

- (void)webView:(UIWebView*)aWebView didFailLoadWithError:(NSError*)error {
	[currentUrl release];
	currentUrl = nil;
	[self webViewDidFinishLoad:aWebView];
}

#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 0) { 
		// open with safari
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:currentUrl]];
	} else if(buttonIndex == 1) { 
		// email this link
		MFMailComposeViewController *mcvc = [[[MFMailComposeViewController alloc] init] autorelease];
		mcvc.mailComposeDelegate = self;
		
		NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
		[mcvc setSubject:title];
		[mcvc setMessageBody:currentUrl isHTML:NO];
		
		[self statusAlertSafelyPresentModalViewController:mcvc animated:YES];
	}
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	if(error)
		SimpleAlertShow(@"Send Error", [error localizedDescription]);
	[controller statusAlertSafelyDismissModalViewControllerAnimated:YES];
}

@end
