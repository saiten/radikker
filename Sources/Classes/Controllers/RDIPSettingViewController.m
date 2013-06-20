//
//  RDIPSettingViewController.m
//  radikker
//
//  Created by saiten on 10/04/07.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPDefines.h"
#import "AppConfig.h"
#import "AppSetting.h"
#import "StatusBarAlert.h"

#import "RDIPSettingViewController.h"
#import "RDIPOAuthViewController.h"
#import "RDIPAboutViewController.h"
#import "RDIPSettingValueSelectViewController.h"

enum {
	SETTINGVIEW_SECTION_TWITTER = 0,
	SETTINGVIEW_SECTION_RADIKO,
	SETTINGVIEW_SECTION_ABOUT,
	SETTINGVIEW_SECTION_COUNT
};

enum {
	SETTINGVIEW_NUMS_TWITTER = 3,
	SETTINGVIEW_NUMS_RADIKO  = 1,
	SETTINGVIEW_NUMS_ABOUT   = 1
};

@interface RDIPSettingViewController(private)
- (UIViewController*)settingValueSelectViewControllerForName:(NSString*)name;
- (NSString*)nameOfValueForKey:(NSString*)key;
@end


@implementation RDIPSettingViewController

#pragma mark -
#pragma mark Initialization

- (id)init
{
	if(self = [super initWithStyle:UITableViewStyleGrouped]) {
	}
	return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
		
	UIBarButtonItem *closeButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																				  target:self 
																				  action:@selector(pressCloseButton:)] autorelease];
	self.navigationItem.rightBarButtonItem = closeButton;
	self.navigationItem.title = NSLocalizedString(@"Settings", @"");
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	[self.tableView reloadData];
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
    return SETTINGVIEW_SECTION_COUNT;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch(section) {
		case SETTINGVIEW_SECTION_TWITTER:
			return NSLocalizedString(@"Twitter", @"");
		case SETTINGVIEW_SECTION_RADIKO:
			return NSLocalizedString(@"Radiko", @"");
	}
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	switch(section) {
		case SETTINGVIEW_SECTION_TWITTER:
			return SETTINGVIEW_NUMS_TWITTER;
		case SETTINGVIEW_SECTION_RADIKO:
			return SETTINGVIEW_NUMS_RADIKO;
		case SETTINGVIEW_SECTION_ABOUT:
			return SETTINGVIEW_NUMS_ABOUT;
	}
    return 0;
}

- (UITableViewCell*)cellForTwitterSectionAtRow:(NSInteger)row
{
	static NSString *cellIdentifier = @"twittercell";
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if(cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
									   reuseIdentifier:cellIdentifier] autorelease];
	}

	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	if(row == 0) {
		cell.textLabel.text = NSLocalizedString(@"Account", @"");
		NSString *screen_name = [[AppSetting sharedInstance] stringForKey:RDIPSETTING_SCREENNAME];
		cell.detailTextLabel.text = screen_name;
		
		if(screen_name)
			cell.accessoryType = UITableViewCellAccessoryNone;
		else
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
	} else if(row == 1) {
		cell.textLabel.text = NSLocalizedString(@"Auto Refresh", @"");
		cell.detailTextLabel.text = [self nameOfValueForKey:RDIPSETTING_AUTOREFRESH];
	} else {
		cell.textLabel.text = NSLocalizedString(@"Initial load", @"");
		cell.detailTextLabel.text = [self nameOfValueForKey:RDIPSETTING_INITIALLOAD];
	}
	
	return cell;
}

- (UITableViewCell*)cellForRadikoSectionAtRow:(NSInteger)row
{
	static NSString *cellIdentifier = @"radikocell";
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if(cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
									   reuseIdentifier:cellIdentifier] autorelease];
	}
	
	if(row == 0) {
		cell.textLabel.text = NSLocalizedString(@"Buffer size", @"");
		cell.detailTextLabel.text = [self nameOfValueForKey:RDIPSETTING_BUFFERSIZE];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else if(row == 1) {
		cell.textLabel.text = NSLocalizedString(@"Initial play", @"");
		cell.detailTextLabel.text = [self nameOfValueForKey:RDIPSETTING_INITIALPLAY];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else {
		cell.textLabel.text = NSLocalizedString(@"Sort tuner", @"");
		cell.detailTextLabel.text = nil;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	return cell;
}

- (UITableViewCell*)cellForAboutSectionAtRow:(NSInteger)row
{
	static NSString *cellIdentifier = @"aboutcell";
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if(cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
									   reuseIdentifier:cellIdentifier] autorelease];
	}

	cell.textLabel.text = NSLocalizedString(@"About radikker", @"");
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
	switch([indexPath section]) {
		case SETTINGVIEW_SECTION_TWITTER:
			return [self cellForTwitterSectionAtRow:(NSInteger)[indexPath row]];
		case SETTINGVIEW_SECTION_RADIKO:
			return [self cellForRadikoSectionAtRow:(NSInteger)[indexPath row]];
		case SETTINGVIEW_SECTION_ABOUT:
			return [self cellForAboutSectionAtRow:(NSInteger)[indexPath row]];
	}

	return nil;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch([indexPath section]) {
		case SETTINGVIEW_SECTION_TWITTER: {
			if([indexPath row] == 0) {
				RDIPOAuthViewController *vc = [[[RDIPOAuthViewController alloc] init] autorelease];
				UINavigationController *nvc = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
				nvc.navigationBar.barStyle = UIBarStyleBlack;
				[self statusAlertSafelyPresentModalViewController:nvc animated:YES];
			} else if([indexPath row] == 1) {
				UIViewController *vc = [self settingValueSelectViewControllerForName:RDIPSETTING_AUTOREFRESH];
				[self.navigationController pushViewController:vc animated:YES];
			} else if([indexPath row] == 2) {
				UIViewController *vc = [self settingValueSelectViewControllerForName:RDIPSETTING_INITIALLOAD];
				[self.navigationController pushViewController:vc animated:YES];
			}
			break;
		}
		case SETTINGVIEW_SECTION_RADIKO: {
			if([indexPath row] == 0) {
				UIViewController *vc = [self settingValueSelectViewControllerForName:RDIPSETTING_BUFFERSIZE];
				[self.navigationController pushViewController:vc animated:YES];
			} else if([indexPath row] == 1) {
				UIViewController *vc = [self settingValueSelectViewControllerForName:RDIPSETTING_INITIALPLAY];
				[self.navigationController pushViewController:vc animated:YES];
			}
			break;
		}
		case SETTINGVIEW_SECTION_ABOUT: {
			if([indexPath row] == 0) {
				RDIPAboutViewController *vc = [[[RDIPAboutViewController alloc] init] autorelease];
				[self.navigationController pushViewController:vc animated:YES];
			}
			break;
		}
	}
}

#pragma mark -
#pragma mark Setting values methods

- (UIViewController*)settingValueSelectViewControllerForName:(NSString*)name
{
	NSDictionary *settingValues = [[AppConfig sharedInstance] objectForKey:RDIPCONFIG_SETTINGVALUES];
	NSDictionary *namesAndValues = [settingValues objectForKey:name];
	
	RDIPSettingValueSelectViewController *vc = [[[RDIPSettingValueSelectViewController alloc] initWithKeyName:name] autorelease];
	vc.title = [namesAndValues objectForKey:RDIPCONFIG_SETTINGVALUES_TITLE];
	vc.valueNames = [namesAndValues objectForKey:RDIPCONFIG_SETTINGVALUES_NAMES];
	vc.values = [namesAndValues objectForKey:RDIPCONFIG_SETTINGVALUES_VALUES];
	
	return vc;
}

- (NSString*)nameOfValueForKey:(NSString*)key
{
	id currentValue = [[AppSetting sharedInstance] objectForKey:key];
	
	NSDictionary *settingValues = [[AppConfig sharedInstance] objectForKey:RDIPCONFIG_SETTINGVALUES];
	NSDictionary *namesAndValues = [settingValues objectForKey:key];

	NSArray *nameArray = [namesAndValues objectForKey:RDIPCONFIG_SETTINGVALUES_NAMES];
	NSArray *valueArray = [namesAndValues objectForKey:RDIPCONFIG_SETTINGVALUES_VALUES];

	int index;
	for(index=0; index<valueArray.count; index++) {
		if([[valueArray objectAtIndex:index] isEqual:currentValue])
			break;
	}
	
	if(index < nameArray.count)
		return [nameArray objectAtIndex:index];
	
	return nil;
}

#pragma mark -
#pragma mark Memory management

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
    [super dealloc];
}

#pragma mark -
#pragma mark original methods

- (void)pressCloseButton:(id)sender
{
	[self statusAlertSafelyDismissModalViewControllerAnimated:YES];
	[self.navigationController setNavigationBarHidden:YES animated:YES];
}

@end

