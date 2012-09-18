//
//  GDataXMLNodeCustomize.m
//  keiba_iphone
//
//  Created by syun on 09/08/05.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GDataXMLNodeUtil.h"


@implementation GDataXMLNode (Util)

- (GDataXMLNode*)nodeForXPath:(NSString*)path error:(NSError**)error
{
	NSArray *nodes = [self nodesForXPath:path error:error];
	
	if(*error || [nodes count] == 0)
		return nil;
	
	return (GDataXMLNode*)[nodes objectAtIndex:0];
}

@end
