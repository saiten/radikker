//
//  NSString+RDIPExtend.h
//  radikker
//
//  Created by saiten  on 10/04/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (RDIPExtend)
- (NSDictionary*)parseURLParameters;
- (NSDate*)dateWithFormat:(NSString*)formatString;
- (NSString*)stringByReplacingUnescapeHTML;
@end
