    //
//  RDIPSubViewController.m
//  radikker
//
//  Created by saiten on 10/04/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPSubViewController.h"
#import "RDIPSquareButton.h"

@interface RDIPSubViewController(private)
- (NSInteger)indexOfButton:(UIControl*)button;
- (void)switchButtonTouchDown:(UIControl*)button;
- (void)switchButtonTouchUp:(UIControl*)button;
- (void)switchButtonTouchCancel:(UIControl*)button;
@end

static NSMutableDictionary *_subViewParentController = nil;

@implementation RDIPSubViewController

- (id)init
{
	if(self = [super init]) {
		selectedIndex = 0;
	}
	return self;
}

- (void)loadView 
{
	[super loadView];
	subView = [[RDIPSubView alloc] initWithFrame:CGRectZero];

	NSArray *switchButtons = [self loadButtons];
	for(UIControl *button in switchButtons) {
		[button addTarget:self action:@selector(switchButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
		[button addTarget:self action:@selector(switchButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
		[button addTarget:self action:@selector(switchButtonTouchCancel:) forControlEvents:UIControlEventTouchUpOutside];
		[button addTarget:self action:@selector(switchButtonTouchCancel:) forControlEvents:UIControlEventTouchCancel];
	}
	
	[subView setSwitchButtons:switchButtons];
	viewControllers = [[self loadViewControllers] retain];

	if(!_subViewParentController)
		_subViewParentController = [[NSMutableDictionary dictionary] retain];
	
	for(UIViewController *vc in viewControllers) {
		NSString *key = [NSString stringWithFormat:@"%d", [vc hash]];
		
		if(![_subViewParentController objectForKey:key]) {
			[_subViewParentController setObject:self forKey:key];
			[self release];
		}
	}
	
	self.view = subView;
}

- (NSArray*)loadButtons
{
	// abstract method
	return [NSArray arrayWithObjects:[[[RDIPSquareButton alloc] initWithTitle:@"Button1"] autorelease],
			                         [[[RDIPSquareButton alloc] initWithTitle:@"Button2"] autorelease], nil];
}

- (NSArray*)loadViewControllers
{
	// abstract method
	return [NSArray arrayWithObjects:[[[UIViewController alloc] init] autorelease],
			                         [[[UIViewController alloc] init] autorelease], nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setSelectedIndex:selectedIndex];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload 
{
	[subView release];
	subView = nil;

	[viewControllers release];
	viewControllers = nil;
	
	currentViewController = nil;
	
    [super viewDidUnload];
}

- (void)dealloc 
{
	[viewControllers release];
	[subView release];

    [super dealloc];
}

#pragma mark -
#pragma mark lifecycle methods

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	
	[currentViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
	
	[currentViewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated 
{
    [super viewWillDisappear:animated];
	
	[currentViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
	
	[currentViewController viewDidDisappear:animated];
}

#pragma mark -
#pragma mark original methods

- (NSInteger)selectedIndex
{
	return selectedIndex;
}

- (void)setSelectedIndex:(NSInteger)i
{
	UIControl *button = [subView.switchButtons objectAtIndex:i];
	[self switchButtonTouchDown:button];
}

- (NSInteger)indexOfController:(UIViewController*)vc
{
	for(int index = 0; index < viewControllers.count; index++) {
		if(vc == [viewControllers objectAtIndex:index])
			return index;
	}
	return -1;
}

- (NSInteger)indexOfButton:(UIControl*)button
{
	for(int index = 0; index < subView.switchButtons.count; index++) {
		if(button == [subView.switchButtons objectAtIndex:index])
			return index;
	}
	return -1;
}

- (UIView*)buttonAtIndex:(NSInteger)index
{
	return [subView.switchButtons objectAtIndex:index];
}

#pragma mark -
#pragma mark switchButtons event methods


- (void)switchButtonTouchDown:(UIControl*)button
{
	BOOL animated = NO;
	UIControl *selectedButton = [subView.switchButtons objectAtIndex:selectedIndex];
	
	selectedButton.selected = NO;
	button.selected = YES;
	selectedIndex = [self indexOfButton:button];

	UIViewController *newViewController = [viewControllers objectAtIndex:selectedIndex];
	if(currentViewController != newViewController) {		
		UIViewController *oldViewController = currentViewController;
		currentViewController = newViewController;
		
		[oldViewController viewWillDisappear:animated];
		[currentViewController viewWillAppear:animated];
		
		subView.containerView = currentViewController.view;
		
		[oldViewController viewDidDisappear:animated];
		[currentViewController viewDidAppear:animated];		
	}
}

- (void)switchButtonTouchUpInside:(UIControl *)button
{
}

- (void)switchButtonTouchCancel:(UIControl *)button
{
}

@end

@implementation UIViewController (RDIPSubViewControllerAddition)

- (RDIPSubViewController*)parentSubViewController
{
	NSString *key = [NSString stringWithFormat:@"%d", [self hash]];
	id con = [_subViewParentController objectForKey:key];
	if(con)
		return (RDIPSubViewController*)con;
	else
		return nil;
}

- (UIView*)subViewButton
{
	if([self.parentSubViewController isKindOfClass:[RDIPSubViewController class]]) {
		RDIPSubViewController *svc = self.parentSubViewController;
		NSInteger index = [svc indexOfController:self];
		if(index >= 0)
			return [svc buttonAtIndex:index];
	}
	return nil;
}

@end

