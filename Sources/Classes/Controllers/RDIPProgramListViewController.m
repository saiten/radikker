//
//  RDIPProgramListViewController.m
//  radikker
//
//  Created by saiten on 10/05/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPProgramListViewController.h"
#import "RDIPWebBrowserController.h"
#import "RDIPAppDelegate.h"
#import "RDIPEPG.h"
#import "RDIPProgramViewCell.h"

@interface RDIPProgramListViewController(private)
- (void)startTimer;
- (void)stopTimer;
- (void)loadProgram;
@end

@implementation RDIPProgramListViewController

#pragma mark -
#pragma mark Initialization

- (id)initWithStation:(RDIPStation*)s
{
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
		station = [s retain];
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];

	self.view.backgroundColor = [UIColor whiteColor];
	self.tableView.scrollEnabled = YES;
	
	indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	CGRect rect = CGRectMake((self.view.frame.size.width - 24)/2, 40, 24, 24);
	indicatorView.frame = rect;
	indicatorView.hidesWhenStopped = YES;	
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	[self startTimer];
	[self loadProgram];
}

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated 
{
    [super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self stopTimer];
}

- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger index = [indexPath row];
	if(programs && index < programs.count)
		return [RDIPProgramViewCell cellHeightForProgram:[programs objectAtIndex:index]];

	return 44.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if(programs)
		return programs.count;
    else
		return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"Cell";
    
	RDIPProgramViewCell *cell = (RDIPProgramViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[RDIPProgramViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
										   reuseIdentifier:CellIdentifier] autorelease];
		UIView *bgView = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		cell.backgroundView = bgView;
		cell.contentView.backgroundColor = [UIColor clearColor];
	}
	
	NSInteger index = [indexPath row];
	if(programs && index < programs.count) {
		RDIPProgram *program = [programs objectAtIndex:index];
		[cell setProgram:program];

		if(program.url && program.url.length > 0) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		if(program == nowOnAir)
			cell.backgroundView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.86 alpha:1.0];
		else if(index % 2 == 1)
			cell.backgroundView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
		else
			cell.backgroundView.backgroundColor = [UIColor whiteColor];
	}
	    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSInteger index = [indexPath row];
	if(programs && index < programs.count) {
		RDIPProgram *program = [programs objectAtIndex:index];
		if(program.url && program.url.length > 0) {
			RDIPWebBrowserController *wbc = [[[RDIPWebBrowserController alloc] init] autorelease];
			[[self mainNavigationController] pushViewController:wbc animated:YES];
			[wbc openURL:program.url];
		}
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload 
{
	[indicatorView release];
	indicatorView = nil;

	[super viewDidUnload];
}


- (void)dealloc {
	[indicatorView release];
	[programs release];
	[station release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark original methods

- (void)startTimer
{
    if(updateTimer == nil) {
		updateTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)10.0
													   target:self 
													 selector:@selector(loadProgram)
													 userInfo:nil 
													  repeats:TRUE];
    }
}

- (void)stopTimer
{
    if(updateTimer) {
		[updateTimer invalidate];
		updateTimer = nil;
    }
}

- (void)loadProgram
{
	NSArray *ps = [[RDIPEPG sharedInstance] programsForStation:station.stationId];
	if(ps) {
		[indicatorView removeFromSuperview];
		[indicatorView stopAnimating];
		
		RDIPProgram *p = [[RDIPEPG sharedInstance] programForStationAtNow:station.stationId];
		if(p && nowOnAir != p) {
			[nowOnAir release];
			nowOnAir = [p retain];		
		}
    
		if(programs != ps) {
			[programs release];
			programs = [ps retain];
		
			[self.tableView reloadData];
            NSInteger index = [[RDIPEPG sharedInstance] indexAtProgram:p forStation:station.stationId];
            if (index >= 0) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                                      atScrollPosition:UITableViewScrollPositionTop
                                              animated:YES];
            }
		}
				
		return;
	}
	
	[self.view addSubview:indicatorView];
	[indicatorView startAnimating];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(RDIPEpgGetProgramNotification:) 
												 name:RDIPEPG_GETPROGRAM_NOTIFICATION
											   object:nil];
}

- (void)RDIPEpgGetProgramNotification:(NSNotification*)notification
{
	NSError *err = [[notification userInfo] objectForKey:RDIPEPG_KEY_ERROR];
	if(err) {
		// TODO
	} else {
		[self loadProgram];
	}	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

