//
//  RDIPNoServiceViewController.m
//  radikker
//
//  Created by saiten on 10/07/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPNoServiceViewController.h"
#import "RDIPAppDelegate.h"
#import "RDIPProgramViewCell.h"
#import "RDIPSquareButton.h"

@interface RDIPInternalNoServiceViewController : UITableViewController
{
	NSString *message;
	UIView *footerView;
}
- (id)initWithMessage:(NSString*)message;
@end

@implementation RDIPInternalNoServiceViewController

- (id)initWithMessage:(NSString *)aMessage
{
	self = [super initWithStyle:UITableViewStyleGrouped];
	message = [aMessage retain];
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor clearColor];
	
	self.tableView.scrollEnabled = NO;

	footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64.0f)];
	
	UIButton *updateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[updateButton setTitle:NSLocalizedString(@"Update Status", @"update_state")
				  forState:UIControlStateNormal];
	[updateButton addTarget:self 
					 action:@selector(pressedUpdateButton:) 
		   forControlEvents:UIControlEventTouchUpInside];

	CGFloat margin = 10.0f;
	CGFloat width = footerView.bounds.size.width - margin*2;
	updateButton.frame = CGRectMake(margin, 10.0f, width, 44.0f);
	[footerView addSubview:updateButton];
}

- (void)dealloc
{
	[message release];
	[footerView release];
	[super dealloc];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath { return 128.0; }
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return 1; }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
	RDIPProgramDescriptionViewCell *cell = 
	    (RDIPProgramDescriptionViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(cell == nil) {
		cell = [[[RDIPProgramDescriptionViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
													  reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	[cell setHTML:message];
	
	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section { return footerView; }

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section { return 64.0f; }

- (void)pressedUpdateButton:(id)sender
{
	RDIPAppDelegate *appDelegate = (RDIPAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate.mainController updateStatus];
}

- (void)programDescriptionCell:(RDIPProgramDescriptionViewCell *)cell didTouchedURL:(NSString *)url
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end

@implementation RDIPNoServiceViewController

- (id)initWithTitle:(NSString *)aTitle message:(NSString*)aMessage
{
	self = [super init];
	title = [aTitle retain];
	message = [aMessage retain];
	return self;
}

- (void)dealloc
{
	[title release];
	[message release];
	[super dealloc];
}

- (NSArray*)loadButtons
{
	RDIPSquareButton *button = [[[RDIPSquareButton alloc] initWithTitle:title] autorelease];
	return [NSArray arrayWithObjects:button, nil];
}

- (NSArray*)loadViewControllers
{
	RDIPInternalNoServiceViewController *viewController = [[[RDIPInternalNoServiceViewController alloc] initWithMessage:message] autorelease];
	return [NSArray arrayWithObjects:viewController, nil];
}

@end