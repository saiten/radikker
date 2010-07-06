//
//  NSString+RDIPExtend.m
//  radikker
//
//  Created by saiten  on 10/04/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSString+RDIPExtend.h"


@implementation NSString (RDIPExtend)

- (NSDictionary*)parseURLParameters
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	
	NSArray *pairs = [self componentsSeparatedByString:@"&"];
	for (NSString *pair in pairs) {
		NSArray *elements = [pair componentsSeparatedByString:@"="];
		if(elements.count == 2) {
			[dic setObject:[elements objectAtIndex:1] 
					forKey:[elements objectAtIndex:0]];
		}			
	}
	
	return dic;
}

- (NSDate*)dateWithFormat:(NSString*)formatString
{
	NSDateFormatter *fmt = [[[NSDateFormatter alloc] init] autorelease];
	[fmt setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"US"] autorelease]];
	[fmt setDateFormat:formatString];
	
	return [fmt dateFromString:self];
}

- (NSString*)stringByReplacingUnescapeHTML
{
	return [[[[self stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"] 
			  stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""]
			 stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"] 
			stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
}

@end
