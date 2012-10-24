//
//  AppSetting.m
//  radikker
//
//  Created by saiten  on 10/04/09.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppSetting.h"

#define APPSETTING_DICTIONARY @"AppSetting"

static AppSetting *_instance = nil;

@implementation AppSetting

+ (id)sharedInstance
{
	if(_instance == nil) {
		_instance = [[AppSetting alloc] init];
	}
	return _instance;
}

- (id)init
{
	if((self = [super init])) {
		NSDictionary *dic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:APPSETTING_DICTIONARY];
		settings = [[NSMutableDictionary dictionaryWithDictionary:dic] retain];
	}
	return self;
}

- (void)removeObjectForKey:(NSString*)key
{
	[settings removeObjectForKey:key];
	[[NSUserDefaults standardUserDefaults] setObject:settings forKey:APPSETTING_DICTIONARY];
	if(![[NSUserDefaults standardUserDefaults] synchronize]) {
		DLog(@"failed synchronize");
	}
}

- (id)objectForKey:(NSString *)key
{
	return [settings objectForKey:key];
}
- (void)setObject:(id)obj forKey:(NSString *)key
{
	[settings setObject:obj forKey:key];
	[[NSUserDefaults standardUserDefaults] setObject:settings forKey:APPSETTING_DICTIONARY];
	if(![[NSUserDefaults standardUserDefaults] synchronize]) {
		DLog(@"failed synchronize");
	}
}

- (NSString*)stringForKey:(NSString *)key
{
	return [self objectForKey:key];
}
- (void)setString:(NSString *)str forKey:(NSString *)key
{
	[self setObject:str forKey:key];
}

- (NSInteger)integerForKey:(NSString *)key
{
	return [(NSNumber*)[self objectForKey:key] intValue];
}
- (void)setInteger:(NSInteger)value forKey:(NSString *)key
{
	[self setObject:[NSNumber numberWithInt:value] forKey:key];
}

- (CGFloat)floatForKey:(NSString *)key
{
	return [(NSNumber*)[self objectForKey:key] floatValue];
}
- (void)setFloat:(CGFloat)value forKey:(NSString *)key
{
	[self setObject:[NSNumber numberWithFloat:value] forKey:key];
}

@end
