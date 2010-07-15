//
//  RDIPProgramViewCell.m
//  radikker
//
//  Created by saiten on 10/04/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPProgramViewCell.h"
#import "RDIPDefines.h"

#define TITLE_FONT       [UIFont boldSystemFontOfSize:16]
#define PERFORMER_FONT   [UIFont boldSystemFontOfSize:14]
#define TIME_FONT        [UIFont boldSystemFontOfSize:14]

@implementation RDIPProgramViewCell

@synthesize titleLabel, performerLabel, timeLabel;

- (void)createViews
{
	titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	titleLabel.font = TITLE_FONT;
	titleLabel.numberOfLines = 0;
	titleLabel.textAlignment = UITextAlignmentLeft;
	titleLabel.textColor = [UIColor darkTextColor];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.highlightedTextColor = [UIColor whiteColor];
	
	performerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	performerLabel.font = PERFORMER_FONT;
	performerLabel.numberOfLines = 0;
	performerLabel.textAlignment = UITextAlignmentLeft;
	performerLabel.textColor = [UIColor darkTextColor];
	performerLabel.backgroundColor = [UIColor clearColor];
	performerLabel.highlightedTextColor = [UIColor whiteColor];
	performerLabel.lineBreakMode = UILineBreakModeTailTruncation;

	timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	timeLabel.font = TIME_FONT;
	timeLabel.textColor = [UIColor darkGrayColor];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.highlightedTextColor = [UIColor whiteColor];
	timeLabel.numberOfLines = 1;
	timeLabel.textAlignment = UITextAlignmentLeft;
	timeLabel.lineBreakMode = UILineBreakModeTailTruncation;

	[self.contentView addSubview:titleLabel];
	[self.contentView addSubview:performerLabel];
	[self.contentView addSubview:timeLabel];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		[self createViews];
    }
    return self;
}

+ (NSString*)stringTime:(RDIPProgram*)program
{
	NSDateFormatter *fmt = [[[NSDateFormatter alloc] init] autorelease];
	[fmt setDateFormat:@"HH:mm"];
	return [NSString stringWithFormat:@"%@ - %@", 
			[fmt stringFromDate:program.fromTime], 
			[fmt stringFromDate:program.toTime]];
}

+ (CGFloat)calculateFrame:(RDIPProgram*)program cell:(RDIPProgramViewCell*)cell
{
	CGFloat height = 8.0f;

	CGSize titleSize = [program.title sizeWithFont:TITLE_FONT 
								 constrainedToSize:CGSizeMake(280, 200)];
	if(cell)
		cell.titleLabel.frame = CGRectMake(10, height, titleSize.width, titleSize.height);
	height += titleSize.height + 4.0f;
	
	CGSize timeSize = [[RDIPProgramViewCell stringTime:program] sizeWithFont:TIME_FONT];
	if(cell)
		cell.timeLabel.frame = CGRectMake(10, height, timeSize.width, timeSize.height);
	height += timeSize.height + 8.0f;
	
	CGSize performerSize = [program.performer sizeWithFont:PERFORMER_FONT 
										 constrainedToSize:CGSizeMake(280, 200)];
	if(cell)
		cell.performerLabel.frame = CGRectMake(10, height, performerSize.width, performerSize.height);
	height += performerSize.height + 8.0f;
	
	return height;
}

+ (CGFloat)cellHeightForProgram:(RDIPProgram *)program
{
	return [RDIPProgramViewCell calculateFrame:program cell:nil];
}

- (void)setProgram:(RDIPProgram *)program
{
	titleLabel.text = program.title;
	performerLabel.text = program.performer;
	timeLabel.text = [RDIPProgramViewCell stringTime:program];
	
	[RDIPProgramViewCell calculateFrame:program cell:self];
}

- (void)dealloc {
	[titleLabel release];
	[performerLabel release];
	[timeLabel release];
	
    [super dealloc];
}

@end

@implementation RDIPProgramDescriptionViewCell

@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
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
	CGRect rect = CGRectInset(self.contentView.frame, 0, 4);
	rect.size.width = 280;
	webView.frame = rect;
}

- (void)setHTML:(NSString *)html
{
	if(html) {
		[webView loadHTMLString:[NSString stringWithFormat:RDIPWEB_DEFAULTHTML_FORMAT, RDIPWEB_DEFAULTHEADER, html] 
						baseURL:nil];	
	}
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
			if(delegate && [delegate respondsToSelector:@selector(programDescriptionCell:didTouchedURL:)])
				[delegate programDescriptionCell:self didTouchedURL:[url absoluteString]];
		}else if([[UIApplication sharedApplication] canOpenURL:url]) {
			[[UIApplication sharedApplication] openURL:url];
		} else {
			return YES;
		}
	}	

	return NO;
}

@end
