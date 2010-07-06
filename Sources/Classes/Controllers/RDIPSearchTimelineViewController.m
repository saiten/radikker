//
//  RDIPSearchTimelineViewController.m
//  radikker
//
//  Created by saiten  on 10/04/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPSearchTimelineViewController.h"
#import "NSString+URLEncoding.h"

@interface RDIPSearchTimelineViewController(private)
- (void)closeKeyboard:(id)sender;

- (void)insertOverlayView;
- (void)removeOverlayView;
- (void)overlayAnimation;
- (void)clearAnimation;
@end

@implementation RDIPSearchTimelineViewController

- (id)init
{
	if(self = [super init]) {
		currentKeyword = [[NSMutableString string] retain];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	searchBar = [[UISearchBar alloc] init];
	searchBar.delegate = self;
	searchBar.barStyle = UIBarStyleDefault;
	searchBar.tintColor = [UIColor grayColor];
	searchBar.text = currentKeyword;
	
	overlayCoverView = [[UIControl alloc] initWithFrame:CGRectZero];
	[overlayCoverView addTarget:self action:@selector(closeKeyboard:) forControlEvents:UIControlEventTouchUpInside];

	self.navigationItem.title = @"Search";
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	[searchBar release];
	searchBar = nil;	
	[overlayCoverView release];
	overlayCoverView = nil;
}

- (void)dealloc
{
	[currentKeyword release];
	[searchBar release];
	[overlayCoverView release];

	[super dealloc];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	return searchBar;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 44.0f;
}

// override method
- (void)loadTimelineWithParams:(NSDictionary*)params
{
	if(!currentKeyword || currentKeyword.length == 0) {
		[self hideLoadingView];
		return;
	}
	
	[self cancel];

	activeClient = [[RDIPTwitterClient alloc] initWithDelegate:self];
	[activeClient getSearchKeyword:currentKeyword params:params];
}

#pragma mark -
#pragma mark original methods

- (NSString*)keyword
{
	return currentKeyword;
}

- (void)setKeyword:(NSString *)s
{
	[currentKeyword setString:s];
	
	if(searchBar) {
		searchBar.text = s;
		[self clearStatuses];
		[self loadLatestTimelineForce:YES];
	}
}

- (void)insertOverlayView
{
	CGRect rect = self.tableView.frame;
	rect.origin.y += 44.0f;
	overlayCoverView.frame = rect;
	overlayCoverView.backgroundColor = [UIColor blackColor];
	overlayCoverView.alpha = 0.0;
	[self.tableView.superview addSubview:overlayCoverView];
}

- (void)removeOverlayView
{
	[overlayCoverView removeFromSuperview];
}

- (void)overlayAnimation
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.2];
	overlayCoverView.alpha = 0.7;
	[UIView commitAnimations];
}

- (void)clearAnimation
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.1];
	[UIView setAnimationDidStopSelector:@selector(removeOverlayView)];
	overlayCoverView.alpha = 0.0;
	[UIView commitAnimations];
}

- (void)closeKeyboard:(id)sender
{
	[self clearAnimation];
	[searchBar resignFirstResponder];
}

#pragma mark -
#pragma mark UISearchBarDelegate methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)aSearchBar
{
	if(activeClient)
		return NO;
	else {
		[self insertOverlayView];
		[self overlayAnimation];
		return YES;
	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
	if(![searchBar.text isEqual:@""] && ![currentKeyword isEqual:searchBar.text]) {
		[currentKeyword setString:searchBar.text];
	
		[self clearStatuses];
		[self loadLatestTimelineForce:YES];
	}

	[searchBar resignFirstResponder];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar
{
	if([searchBar.text isEqual:@""])
		[self clearStatuses];
	
	[self clearAnimation];
	[searchBar resignFirstResponder];
}

@end
