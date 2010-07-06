//
//  RDIPSettingValueSelectViewController.m
//  radikker
//
//  Created by saiten on 10/04/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPSettingValueSelectViewController.h"
#import "AppSetting.h"

@implementation RDIPSettingValueSelectViewController

@synthesize title, valueNames, values;

#pragma mark -
#pragma mark Initialization

- (id)initWithKeyName:(NSString *)aKeyName
{
	if(self = [super initWithStyle:UITableViewStyleGrouped]) {
		keyName = [aKeyName retain];
	}

	return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	self.navigationController.title = title;
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
    return values.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	id value = [values objectAtIndex:indexPath.row];
	if(indexPath.row < valueNames.count) {
		cell.textLabel.text = [valueNames objectAtIndex:indexPath.row];
	} else {
		if([value respondsToSelector:@selector(stringValue)])
			cell.textLabel.text = [value stringValue];
		else
			cell.textLabel.text = [NSString stringWithFormat:@"value %d", indexPath.row];
	}
	
	id currentValue = [[AppSetting sharedInstance] objectForKey:keyName];
	if([value isEqual:currentValue])
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else 
		cell.accessoryType = UITableViewCellAccessoryNone;
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	id oldValue = [[AppSetting sharedInstance] objectForKey:keyName];
	if(indexPath.row < values.count) {
		id value = [values objectAtIndex:indexPath.row];

		if([oldValue isEqual:value]) {
			[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
			return;
		}

		int index;
		for(index=0; index<values.count; index++) {
			if([[values objectAtIndex:index] isEqual:oldValue])
				break;
		}
			
		if(index < values.count) {
			UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:
										[NSIndexPath indexPathForRow:index inSection:0]];
			oldCell.accessoryType = UITableViewCellAccessoryNone;
		}
		
		[self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
		[[AppSetting sharedInstance] setObject:value forKey:keyName];
	}

	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload 
{	
}


- (void)dealloc 
{
	[title release];
	[keyName release];
	[valueNames release];
	[values release];

    [super dealloc];
}


@end

