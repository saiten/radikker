//
//  NSDate+RDIPExtend.m
//  radikker
//
//  Created by saiten  on 10/04/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSDate+RDIPExtend.h"


@implementation NSDate (RDIPExtend)

- (NSString*)stringWithFormat:(NSString*)format locale:(NSLocale*)locale
{
	NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
	[fmt setLocale:locale];
	[fmt setDateFormat:format];
	NSString *s = [fmt stringFromDate:self];
	
	[fmt release];
	return s;
}

- (NSString*)stringWithFormat:(NSString*)format
{
	return [self stringWithFormat:format locale:[NSLocale currentLocale]];
}

@end
