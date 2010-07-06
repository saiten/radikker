//
//  RDIPStatusProfileViewCell.m
//  radikker
//
//  Created by saiten on 10/05/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDIPStatusProfileViewCell.h"

@implementation RDIPStatusProfileViewCell

@synthesize delegate;

- (void)createViews
{
	profileImageView = [[RDIPProfileImageView alloc] initWithFrame:CGRectZero];

	nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	nameLabel.font = [UIFont boldSystemFontOfSize:16];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.textColor = [UIColor darkTextColor];
	nameLabel.shadowColor = [UIColor whiteColor];
	nameLabel.shadowOffset = CGSizeMake(0, 1);
	nameLabel.numberOfLines = 1;
	nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
	nameLabel.textAlignment = UITextAlignmentLeft;

	screenNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	screenNameLabel.font = [UIFont boldSystemFontOfSize:14];
	screenNameLabel.backgroundColor = [UIColor clearColor];
	screenNameLabel.textColor = [UIColor darkGrayColor];
	screenNameLabel.shadowColor = [UIColor whiteColor];
	screenNameLabel.shadowOffset = CGSizeMake(0, 1);
	screenNameLabel.numberOfLines = 1;
	screenNameLabel.lineBreakMode = UILineBreakModeTailTruncation;
	screenNameLabel.textAlignment = UITextAlignmentLeft;
	
	[self.contentView addSubview:profileImageView];
	[self.contentView addSubview:nameLabel];
	[self.contentView addSubview:screenNameLabel];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.backgroundColor = [UIColor clearColor];
		
		[self createViews];
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect rect = CGRectInset(self.contentView.frame, 0, 0);
	CGFloat marginTop = (rect.size.height - 64.0) / 2;
	profileImageView.frame = CGRectMake(16, marginTop + 6, 48, 48);
	nameLabel.frame = CGRectMake(74, marginTop + 8, 220, 18);
	screenNameLabel.frame = CGRectMake(74, marginTop + 36, 220, 14);
}

- (void)setUser:(RDIPTwitterUser *)user
{

	if(user.name)
		nameLabel.text = user.name;
	else
		nameLabel.text = user.screenName;

	screenNameLabel.text = [NSString stringWithFormat:@"@%@", user.screenName];
	[profileImageView setProfileImageURL:user.imageUrl];
}

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch *touch = [touches anyObject];
	
	if([touch tapCount] == 1) {
		if(delegate && [delegate respondsToSelector:@selector(statusProfileViewCellTapped:)])
			[delegate statusProfileViewCellTapped:self];
	}
}

- (void)dealloc 
{
	[profileImageView release];
	[nameLabel release];
	[screenNameLabel release];

    [super dealloc];
}

@end
