//
//  RDIPAboutViewController.m
//  radikker
//
//  Created by saiten on 10/07/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPAboutViewController.h"


@implementation RDIPAboutViewController

- (void)loadView
{
	[super loadView];
	
	webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
	webView.backgroundColor = [UIColor whiteColor];
	webView.delegate = self;
	webView.scalesPageToFit = YES;
	webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	webView.autoresizesSubviews = YES;

	[self.view addSubview:webView];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.navigationItem.title = NSLocalizedString(@"About radikker", @"");
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"];
	NSURL *url = [[[NSURL alloc] initFileURLWithPath:path] autorelease];
	[webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
	NSString *replaceVersion = @"document.getElementById('version').innerHTML = '%@'";
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:replaceVersion, version]];
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if ([request.URL.scheme isEqualToString:@"http"]) {
		[[UIApplication sharedApplication] openURL:request.URL];
		return NO;
	}
	return YES;
}

- (void)dealloc
{
	[webView release];
	[super dealloc];
}

@end
