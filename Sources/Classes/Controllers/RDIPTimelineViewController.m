//
//  RDIPTimelineViewController.m
//  radikker
//
//  Created by saiten on 10/04/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPTimelineViewController.h"
#import "RDIPTwitterStatus.h"
#import "AppSetting.h"
#import "RDIPDefines.h"
#import "SimpleAlert.h"

#import "RDIPStatusViewCell.h"
#import "RDIPLoadingViewCell.h"

#import "RDIPAppDelegate.h"
#import "RDIPStatusViewController.h"

@interface RDIPTimelineViewController (private)
- (NSArray*)_uniqueArray:(NSArray*)arr;

@end

@implementation RDIPTimelineViewController

#pragma mark -
#pragma mark Initialization

- (id)init
{
	if(self = [super initWithStyle:UITableViewStylePlain]) {
	}
	return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];

	moreLoadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	moreLoadingIndicatorView.hidesWhenStopped = YES;
	moreLoadingIndicatorView.frame = CGRectMake(148, 10, 24, 24);

	loadingView = [[UIView alloc] initWithFrame:CGRectZero];
	loadingView.backgroundColor = [UIColor whiteColor];
	
	UIActivityIndicatorView *indicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
	indicatorView.frame = CGRectMake(148, 100, 24, 24);

	[loadingView addSubview:indicatorView];
	[indicatorView startAnimating];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	[self loadLatestTimelineForce:NO];
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

- (RDIPTwitterStatus*)statusAtIndexPath:(NSIndexPath*)indexPath
{
	NSInteger index = [indexPath row] - 1;
	if(index >= 0 && index < statuses.count)
		return [statuses objectAtIndex:index];

	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if(statuses) {
		NSInteger count = statuses.count;
		if(statuses.count > 0)
			return count + 2;
		else
			return count + 1;
	} else
		return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *StatusCellIdentifier = @"StatusCell";
    static NSString *LoadingCellIdentifier = @"LoadingCell";
    static NSString *AutoLoadCellIdentifier = @"AutoLoadCell";

	RDIPTwitterStatus *status = [self statusAtIndexPath:indexPath];

	// status cell
	if(status) {
		RDIPStatusViewCell *cell = (RDIPStatusViewCell*)[tableView dequeueReusableCellWithIdentifier:StatusCellIdentifier];
		if (cell == nil) {
			cell = [[[RDIPStatusViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
											  reuseIdentifier:StatusCellIdentifier] autorelease];
		}
				
		[cell setStatus:status];
		return cell;
	}
	
	// refresh cell
	if([indexPath row] == 0) {
		RDIPLoadingViewCell *cell = (RDIPLoadingViewCell*)[tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier];
		if(cell == nil) {
			cell = [[[RDIPLoadingViewCell alloc] initWithStyle:UITableViewCellStyleDefault
											   reuseIdentifier:LoadingCellIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		}

		[cell setLoading:(activeClient != nil)];
		return cell;
	}

	// auto loading cell
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AutoLoadCellIdentifier];
	if(cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:AutoLoadCellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		[cell.contentView addSubview:moreLoadingIndicatorView];
	}

	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	RDIPTwitterStatus *status = [self statusAtIndexPath:indexPath];

	if(status) {
		RDIPStatusViewController *vc = [[[RDIPStatusViewController alloc] initWithStatus:status] autorelease];
		
		[[self mainNavigationController] pushViewController:vc animated:YES];								
	} else {
		if([indexPath row] == 0) {
			if(activeClient != nil) {
				[self cancel];
				[(RDIPLoadingViewCell*)[tableView cellForRowAtIndexPath:indexPath] setLoading:NO];
			} else {
				[self loadLatestTimelineForce:YES];
				[(RDIPLoadingViewCell*)[tableView cellForRowAtIndexPath:indexPath] setLoading:YES];
			}
			[tableView deselectRowAtIndexPath:indexPath animated:NO];
		}
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	RDIPTwitterStatus *status = [self statusAtIndexPath:indexPath];
	if(status)
		return [RDIPStatusViewCell cellHeightForStatus:status];
	else {
		
	}
	
	return 44.0;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	[moreLoadingIndicatorView release];
	moreLoadingIndicatorView = nil;
	
	[loadingView release];
	loadingView = nil;
}

- (void)dealloc {
	[moreLoadingIndicatorView release];
	[loadingView release];
	
	[statuses release];
	[activeClient cancel];
	[activeClient release];
	[lastUpdate release];

    [super dealloc];
}

#pragma mark -
#pragma mark UIScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height) {
		if(activeClient == nil) {
			[self loadTimelineBeforeStatusID:[(RDIPTwitterStatus*)[statuses lastObject] statusId] 
									   count:20];
			[moreLoadingIndicatorView startAnimating];
		}
	}
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

- (void)clearStatuses
{
	[statuses release];
	statuses = nil;
	[self.tableView reloadData];
}

- (void)showLoadingView
{
	CGRect rect = self.view.frame;
	CGFloat marginTop = 0.0f;
	if(self.tableView && [self respondsToSelector:@selector(tableView:heightForHeaderInSection:)])
		marginTop = [self tableView:self.tableView heightForHeaderInSection:0];

	loadingView.frame = CGRectMake(0, marginTop, rect.size.width, rect.size.height);
	self.tableView.scrollEnabled = NO;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.tableView addSubview:loadingView];
}

- (void)hideLoadingView
{
	[loadingView removeFromSuperview];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.tableView.scrollEnabled = YES;	
}

// override method
- (void)loadTimelineWithParams:(NSDictionary*)params
{
	[self cancel];
	
	activeClient = [[RDIPTwitterClient alloc] initWithDelegate:self];
	[activeClient getHomeTimelineWithParams:params];
}

- (void)loadLatestTimelineForce:(BOOL)force
{
	if(!force && (statuses && statuses.count > 0)) {
		int autoRefreshSec = [[[AppSetting sharedInstance] objectForKey:RDIPSETTING_AUTOREFRESH] intValue];
		if(autoRefreshSec > 0 && lastUpdate) {
			NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:lastUpdate];
			if(interval > autoRefreshSec * 1000)
				[self loadLatestTimelineImpl];
		}
	} else {
		if(!statuses || statuses.count == 0)
			[self showLoadingView];

		[self loadLatestTimelineImpl];
	}
}

- (void)loadLatestTimelineImpl
{
	NSMutableDictionary *params = [NSMutableDictionary dictionary];

	if(statuses && statuses.count > 0) {
		RDIPTwitterStatus *lastStatus = [statuses objectAtIndex:0];
		[params setObject:[NSString stringWithFormat:@"%qu", lastStatus.statusId] forKey:@"since_id"];
	} else {
		UInt32 initialCount = [[[AppSetting sharedInstance] objectForKey:RDIPSETTING_INITIALLOAD] unsignedIntValue];
		[params setObject:[NSString stringWithFormat:@"%u", initialCount] forKey:@"count"];
	}
	
	[self loadTimelineWithParams:params];
}

- (void)loadTimelineBeforeStatusID:(UInt64)statusId count:(UInt32)count
{
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[NSString stringWithFormat:@"%qu", statusId] forKey:@"max_id"];
	[params setObject:[NSString stringWithFormat:@"%u", count] forKey:@"count"];
	
	[moreLoadingIndicatorView startAnimating];
	[self loadTimelineWithParams:params];
}

- (NSArray*)_uniqueArray:(NSArray*)arr
{
	if(arr.count < 2)
		return arr;
	
	NSMutableArray *uniqueArr = [NSMutableArray arrayWithArray:arr];
	NSMutableIndexSet *removeIndexes = [NSMutableIndexSet indexSet];

	// unique statuses
	for(int i=0; i<arr.count-1; i++) {
		for(int j=i+1; j<arr.count; j++) {

			if([[arr objectAtIndex:i] isEqual:[arr objectAtIndex:j]])
				[removeIndexes addIndex:j];
		}
	}
		
	[uniqueArr removeObjectsAtIndexes:removeIndexes];
	return uniqueArr;
}

#pragma mark -
#pragma mark RDIPTimelineClient Delegate methods

- (void)timelineClient:(RDIPTwitterClient*)timelineClient didGetTimeline:(NSArray*)timeline
{	
	NSArray *sortedStatuses = nil;
	if(statuses) {
		sortedStatuses = [[statuses arrayByAddingObjectsFromArray:timeline] sortedArrayUsingSelector:@selector(compareLatest:)];
	} else {
		sortedStatuses = [timeline sortedArrayUsingSelector:@selector(compareLatest:)];
	}
	
	[statuses release];
	statuses = [[self _uniqueArray:sortedStatuses] retain];	
	
	[lastUpdate release];
	lastUpdate = [[NSDate date] retain];
	
	[activeClient autorelease];
	activeClient = nil;
	
	[moreLoadingIndicatorView stopAnimating];

	[self hideLoadingView];
	[self.tableView reloadData];
}

- (void)timelineClient:(RDIPTwitterClient*)timelineClient didFailWithError:(NSError*)error
{
	SimpleAlertShow(@"Load Error", [error localizedDescription]);
	
	[activeClient autorelease];
	activeClient = nil;

	[self hideLoadingView];
	[moreLoadingIndicatorView stopAnimating];
}

@end

