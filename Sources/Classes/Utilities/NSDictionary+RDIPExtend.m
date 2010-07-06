//
//  NSDictionary+RDIPExtend.m
//  radikker
//
//  Created by saiten  on 10/04/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+RDIPExtend.h"


@implementation NSDictionary (RDIPExtend)

- (id)myObjectForKey:(id)aKey
{
	id obj = [self objectForKey:aKey];
	if([obj isKindOfClass:[NSNull class]])
		return nil;

	return obj;
}

- (NSString*)stringForKey:(NSString *)key
{
	id obj = [self myObjectForKey:key];
	if([obj isKindOfClass:[NSString class]])
		return (NSString*)obj;
	else
		return nil;
}

@end
