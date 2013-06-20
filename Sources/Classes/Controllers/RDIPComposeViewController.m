    //
//  RDIPComposeViewController.m
//  radikker
//
//  Created by saiten on 10/04/21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPComposeViewController.h"
#import "StatusBarAlert.h"
#import "SimpleAlert.h"

@interface RDIPComposeViewController(private)
- (void)pressCancelButton:(id)sender;
- (void)pressPostButton:(id)sender;
@end

@implementation RDIPComposeViewController

@synthesize postStatus, selectRange;

- (id)initWithText:(NSString *)aText
{
	if(self = [super init]) {
		text = [aText retain];
	}

	return self;
}

- (void)loadView {
	[super loadView];

	closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"compose_view_closebutton")
												   style:UIBarButtonItemStyleBordered
												  target:self 
												  action:@selector(pressCloseButton:)];
	
	cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																 target:self
																 action:@selector(pressCancelButton:)];

	postButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Post", @"compose_view_postbutton")
												  style:UIBarButtonItemStyleDone
												 target:self 
												 action:@selector(pressPostButton:)];

	composeView = [[RDIPComposeView alloc] initWithFrame:self.view.bounds];
	composeView.delegate = self;
    [self.view addSubview:composeView];
}

- (void)setSendingNavigationBar
{
	self.navigationItem.leftBarButtonItem = nil;
	self.navigationItem.rightBarButtonItem = cancelButton; 
}

- (void)setEditingNavigationBar
{
	self.navigationItem.leftBarButtonItem = closeButton;
	self.navigationItem.rightBarButtonItem = postButton; 
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.navigationItem.title = NSLocalizedString(@"New Tweet", @"compose_view_title");
	composeView.text = text;
    [self composeViewDidChange:composeView];

	[self setEditingNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	
	text = [composeView.text retain];
	
	[composeView release];
	composeView = nil;
	
	[closeButton release];
	closeButton = nil;
	[cancelButton release];
	cancelButton = nil;
	[postButton release];
	postButton = nil;
}

- (void)dealloc {
	[postStatus release];
	
	[text release];
	[composeView release];

	[closeButton release];
	[cancelButton release];
	[postButton release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark property methods

- (NSString*)text
{
	if(composeView)
		text = [composeView.text retain];
	return text;
}

- (void)setText:(NSString *)s
{
	text = [s retain];
	if(composeView)
		composeView.text = text;

    [self composeViewDidChange:composeView];
	selectRange = NSMakeRange(0, 0);
}

#pragma mark -
#pragma mark lifecycle methods

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
	[postStatus release];
	postStatus = nil;
	[composeView showKeyboard];
	composeView.selectRange = selectRange;
}

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated 
{
    [super viewWillDisappear:animated];
	selectRange = composeView.selectRange;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
}

#pragma mark - keyboard notification

-(void)keyboardWillShow:(NSNotification*)note
{
    CGRect keyboardFrame = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect rect = self.view.frame;
    rect.size.height -= self.view.bounds.size.height - keyboardFrame.origin.y + 44.0f + 20.0f;
    composeView.frame = rect;
}
#pragma mark -
#pragma mark original methods

- (void)cancel
{
	if(activeClient) {
		[activeClient cancel];
		[activeClient autorelease];
		activeClient = nil;
	}
}

#pragma mark -
#pragma mark NavigationBar Button events methods

- (void)pressCloseButton:(id)sender
{
	[self statusAlertSafelyDismissModalViewControllerAnimated:YES];
}

- (void)pressCancelButton:(id)sender
{
	[self cancel];
	[composeView hideOverlay];
	[self setEditingNavigationBar];
}

- (void)pressPostButton:(id)sender
{
	if(activeClient == nil) {
		[composeView showOverlay];
		[self setSendingNavigationBar];
		
		activeClient = [[RDIPTwitterClient alloc] initWithDelegate:self];
		[activeClient updateStatus:self.text];
	}	
}

#pragma mark -
#pragma mark RDIPComposeView delegate methods

- (void)composeViewDidChange:(RDIPComposeView*)aComposeView
{
	if(self.text) {
		NSInteger count = 140 - self.text.length;
		if(count >= 0 && count < 140)
			postButton.enabled = YES;
		else
			postButton.enabled = NO;
	}
}

#pragma mark -
#pragma mark RDIPTwitterClient delegate methods

- (void)timelineClient:(RDIPTwitterClient*)timelineClient didGetTimeline:(NSArray*)timeline
{
	[activeClient autorelease];
	activeClient = nil;

	self.text = @"";

	if(timeline.count > 0) {
		[postStatus release];
		postStatus = [timeline objectAtIndex:0];
		[postStatus retain];
	}
	
	[composeView hideOverlay];
	[self setEditingNavigationBar];
	[self statusAlertSafelyDismissModalViewControllerAnimated:YES];
}

- (void)timelineClient:(RDIPTwitterClient*)timelineClient didFailWithError:(NSError*)error
{
	SimpleAlertShow(@"Tweet Error", [error localizedDescription]);
	
	[activeClient autorelease];
	activeClient = nil;

	[composeView hideOverlay];
	[self setEditingNavigationBar];
}


@end
