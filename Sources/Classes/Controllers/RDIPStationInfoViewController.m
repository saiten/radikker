//
//  RDIPStationInfoViewController.m
//  radikker
//
//  Created by saiten on 10/04/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SimpleAlert.h"
#import "StatusBarAlert.h"

#import "RDIPStationInfoViewController.h"
#import "RDIPProgramViewCell.h"
#import "RDIPEPG.h"
#import "RDIPWebBrowserController.h"

#import "RDIPAppDelegate.h"

@interface RDIPStationInfoViewController(private)
- (void)startTimer;
- (void)stopTimer;
- (void)loadProgram;
@end

@implementation RDIPStationInfoViewController

- (id)initWithStation:(RDIPStation*)s
{
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
		station = [s retain];
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor clearColor];

	self.tableView.scrollEnabled = NO;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor lightGrayColor];
    
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
	CGFloat programCellHeight;
    if(program.title)
        programCellHeight = [RDIPProgramViewCell cellHeightForProgram:program];
    else
        programCellHeight = [RDIPProgramViewCell cellHeightForStation:station];
  
	if([indexPath section] == 0) {
		switch([indexPath row]) {
			case 0:
				return programCellHeight;
			case 1:
				return self.tableView.frame.size.height - 18 - programCellHeight;
		}
	}
	
	return 44.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if(program)
		return 2;
	else
		return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *ProgramCellIdentifier = @"ProgramViewCell";
	static NSString *DescriptionCellIdentifier = @"DescriptionViewCell";

    if([indexPath section] == 0) {
		if([indexPath row] == 0) {
			RDIPProgramViewCell *cell = 
			(RDIPProgramViewCell*)[tableView dequeueReusableCellWithIdentifier:ProgramCellIdentifier];
			if (cell == nil) {
				cell = [[[RDIPProgramViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
												   reuseIdentifier:ProgramCellIdentifier] autorelease];
			}
			if(program.title) {
				[cell setProgram:program];
        
        if(program.url && program.url.length > 0) {
          cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
          cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        } else {
          cell.accessoryType = UITableViewCellAccessoryNone;
          cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
      } else {
        [cell setStation:station];        
      }


			return cell;
		} else if([indexPath row] == 1) {
			RDIPProgramDescriptionViewCell *cell =
			(RDIPProgramDescriptionViewCell*)[tableView dequeueReusableCellWithIdentifier:DescriptionCellIdentifier];
			
			if (cell == nil) {
				cell = [[[RDIPProgramDescriptionViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
															  reuseIdentifier:DescriptionCellIdentifier] autorelease];
				cell.delegate = self;
			}

			if(program)
				[cell setHTML:program.description];
			
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			return cell;
		}
	}

    return nil;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if([indexPath section] == 0) {
		if([indexPath row] == 0) {
			if(program.url && program.url.length > 0) {
				RDIPWebBrowserController *wbc = [[[RDIPWebBrowserController alloc] init] autorelease];
				[[self mainNavigationController] pushViewController:wbc animated:YES];
				[wbc openURL:program.url];
			}
		}
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	[indicatorView release];
	indicatorView = nil;

	[super viewDidUnload];	
}

- (void)dealloc {
	[indicatorView release];
	[program release];
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
	RDIPProgram *p = [[RDIPEPG sharedInstance] programForStationAtNow:station.stationId];
	if(p) {
		[indicatorView removeFromSuperview];
		[indicatorView stopAnimating];
		
		if(p == program)
			return;
		
		[program release];
		program = [p retain];

		[self.tableView reloadData];
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

#pragma mark -
#pragma mark RDIPProgramDescriptionViewCellDelegate methods

- (void)programDescriptionCell:(RDIPProgramDescriptionViewCell *)cell didTouchedURL:(NSString *)url
{
	NSString *scheme = [[NSURL URLWithString:url] scheme];
	
	if([scheme isEqual:@"mailto"]){
		if(![MFMailComposeViewController canSendMail]) {
			SimpleAlertShow(@"Error", NSLocalizedString(@"This device can not send mail.", @"sendmail_error"));
			return;
		}			

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

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	if(error)
		SimpleAlertShow(@"Send Error", [error localizedDescription]);
	[controller statusAlertSafelyDismissModalViewControllerAnimated:YES];
}

@end

