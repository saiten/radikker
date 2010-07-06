//
//  RDIPStatusDetailViewCell.m
//  radikker
//
//  Created by saiten  on 10/04/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPStatusDetailViewCell.h"
#import "RDIPDefines.h"
#import "NSString+RDIPExtend.h"
#import "RegexKitLite.h"

@implementation RDIPStatusDetailViewCell

@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		webView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 2, 280, 156)];
		webView.delegate = self;
		webView.backgroundColor = [UIColor whiteColor];
		webView.scalesPageToFit = YES;
		webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		webView.autoresizesSubviews = YES;
		
		[self.contentView addSubview:webView];
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect rect = CGRectInset(self.contentView.frame, 0, 6);
	rect.size.width = 280;
	webView.frame = rect;
}

- (void)setStatus:(RDIPTwitterStatus *)status
{
	NSString *footer = [NSString stringWithFormat:@"%@ via %@", [status stringCreatedSinceNow], [status.source stringByReplacingUnescapeHTML]];
	NSString *body = [NSString stringWithFormat:@"<div id=\"text\">%@</div><div id=\"foot\">%@</div>", [status textByAppendLinks], footer];

	[webView loadHTMLString:[NSString stringWithFormat:RDIPWEB_DEFAULTHTML_FORMAT, RDIPWEB_DEFAULTHEADER, body] 
					baseURL:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
    [super setSelected:selected animated:animated];
}

- (void)dealloc 
{
	[webView release];
    [super dealloc];
}

#pragma mark -
#pragma mark UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)req navigationType:(UIWebViewNavigationType)navigationType
{
	if(req) {
		NSURL *url = [req URL];
		NSString *scheme = [url scheme];
		if([scheme isEqual:@"http"] || [scheme isEqual:@"https"] || [scheme isEqual:@"mailto"]) {			
			if(delegate && [delegate respondsToSelector:@selector(statusDetailViewCell:didTouchedURL:)])
				[delegate statusDetailViewCell:self didTouchedURL:[url absoluteString]];
		} else if([scheme isEqual:@"rdip"]) {
			NSString *host = [url host];
			NSString *key = nil;
			if([url path].length > 0)
				key = [[url path] substringFromIndex:1];

			if([host isEqual:@"user"]) {
				if(delegate && [delegate respondsToSelector:@selector(statusDetailViewCell:didTouchedUser:)])
					[delegate statusDetailViewCell:self didTouchedUser:key];
			} else if([host isEqual:@"search"]) {
				if(delegate && [delegate respondsToSelector:@selector(statusDetailViewCell:didTouchedHash:)])
					[delegate statusDetailViewCell:self didTouchedHash:key];
			}
		}else if([[UIApplication sharedApplication] canOpenURL:url]) {
			[[UIApplication sharedApplication] openURL:url];
		} else {
			return YES;
		}
	}	
	return NO;
}

@end