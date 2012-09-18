//
//  GDataXMLNodeCustomize.h
//  keiba_iphone
//
//  Created by syun on 09/08/05.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GDataXMLNode.h"

@interface GDataXMLNode (Util)

- (GDataXMLNode*)nodeForXPath:(NSString*)path error:(NSError**)error;

@end
