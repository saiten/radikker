//
//  SharedImageStore.m
//  radikker
//
//  Created by saiten on 10/03/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SharedImageStore.h"

static ImageStore *_instance = nil;

@implementation SharedImageStore

+ (id)sharedInstance
{
	if(_instance == nil) {
		_instance = [[SharedImageStore alloc] init];
	}

	return _instance;
}

- (id)init
{
	if((self = [super init])) {
		imageStore = [[ImageStore alloc] initWithDelegate:self];
	}

	return self;
}

- (UIImage*)getImage:(NSString *)url
{
	return [imageStore getImage:url];
}

- (void)imageStoreDidGetNewImage:(ImageStore*)sender url:(NSString*)url
{
	NSDictionary *dic = [NSDictionary dictionaryWithObject:url forKey:SHAREDIMAGESTORE_KEY_REQUESTURL];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:SHAREDIMAGESTORE_GETNEWIMAGE_NOTIFICATION
														object:self 
													  userInfo:dic];
}

- (void)dealloc
{
	[imageStore release];
	[super dealloc];
}

@end
