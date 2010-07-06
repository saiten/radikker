//
//  RDIPStatusViewController.m
//  radikker
//
//  Created by saiten on 10/05/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPStatusViewController.h"
#import "RDIPStatusProfileViewCell.h"
#import "RDIPStatusDetailViewCell.h"
#import "RDIPStatusFooterView.h"

#import "SimpleAlert.h"
#import "StatusBarAlert.h"

#import "RDIPAppDelegate.h"
#import "RDIPWebBrowserController.h"
#import "RDIPUserTimelineViewController.h"
#import "RDIPSearchTimelineViewController.h"

@implementation RDIPStatusViewController

#pragma mark -
#pragma mark Initialization

- (id)initWithStatus:(RDIPTwitterStatus *)aStatus
{
	if((self = [super initWithStyle:UITableViewStyleGrouped])) {
		status = [aStatus retain];				
	}
	return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)createViews
{
	profileCell = [[RDIPStatusProfileViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
												   reuseIdentifier:@"ProfileCell"];
	profileCell.selectionStyle = UITableViewCellSelectionStyleNone;
	profileCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	profileCell.delegate = self;
	[profileCell setUser:status.user];	
	
	statusCell = [[RDIPStatusDetailViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
												 reuseIdentifier:@"StatusCell"];
	statusCell.selectionStyle = UITableViewCellSelectionStyleNone;
	statusCell.delegate = self;
	[statusCell setStatus:status];
	
	footerView = [[RDIPStatusFooterView alloc] initWithFrame:CGRectZero];
	footerView.delegate = self;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];

	[self createViews];

	self.tableView.scrollEnabled = NO;
	self.navigationItem.title = @"Tweet";
}

- (void)viewWillAppear:(BOOL)animated 
{	
    [super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	[self.navigationController setToolbarHidden:YES animated:YES];	
}

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated 
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
	return statusCell;
}

#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 200.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	return profileCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 84.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 64.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload 
{
	[profileCell release];
	profileCell = nil;
	[statusCell release];
	statusCell = nil;
	[footerView release];
	footerView = nil;
}

- (void)dealloc {
	[status release];
	[profileCell release];
	[statusCell release];
	[footerView release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark RDIPStatusProfileViewCellDelegate methods

- (void)statusProfileViewCellTapped:(RDIPStatusProfileViewCell *)statusProfileViewCell
{
	RDIPUserTimelineViewController *utvc = [[[RDIPUserTimelineViewController alloc] initWithScreenName:status.user.screenName] autorelease];
	[[self mainNavigationController] pushViewController:utvc animated:YES];
}

#pragma mark -
#pragma mark RDIPStatusDetailViewCellDelegate methods

- (void)statusDetailViewCell:(RDIPStatusDetailViewCell*)cell didTouchedURL:(NSString *)url
{
	NSString *scheme = [[NSURL URLWithString:url] scheme];
	
	if([scheme isEqual:@"mailto"]){
		MFMailComposeViewController *mcvc = [[[MFMailComposeViewController alloc] init] autorelease];
		mcvc.mailComposeDelegate = self;
		[mcvc setToRecipients:[NSArray arrayWithObject:[url substringFromIndex:7]]];
		
		[[self mainNavigationController] statusAlertSafelyPresentModalViewController:mcvc animated:YES];
	} else {
		RDIPWebBrowserController *wbc = [[[RDIPWebBrowserController alloc] init] autorelease];
		[[self mainNavigationController] pushViewController:wbc animated:YES];
		[wbc openURL:url];
	}
}

- (void)statusDetailViewCell:(RDIPStatusDetailViewCell*)cell didTouchedUser:(NSString *)user
{
	RDIPUserTimelineViewController *utvc = [[[RDIPUserTimelineViewController alloc] initWithScreenName:user] autorelease];
	[[self mainNavigationController] pushViewController:utvc animated:YES];
}

- (void)statusDetailViewCell:(RDIPStatusDetailViewCell*)cell didTouchedHash:(NSString *)hash
{
	RDIPSearchTimelineViewController *stvc = [[[RDIPSearchTimelineViewController alloc] init] autorelease];
	stvc.keyword = hash;
	[[self mainNavigationController] pushViewController:stvc animated:YES];	
}

#pragma mark -
#pragma mark RDIPStatusFooterViewDelegate methods

- (void)statusFooterViewDidTouchedReplyButton
{
	NSString *text = [NSString stringWithFormat:@" @%@", status.user.screenName];
	[self presentComposeViewControllerWithText:text force:YES];
}

- (void)statusFooterViewDidTouchedRetweetButton
{
	NSString *text = [NSString stringWithFormat:@" RT @%@: %@", status.user.screenName, status.text];
	[self presentComposeViewControllerWithText:text force:YES];
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

