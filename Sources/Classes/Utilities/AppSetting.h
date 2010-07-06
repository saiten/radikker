//
//  AppSetting.h
//  radikker
//
//  Created by saiten  on 10/04/09.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppSetting : NSObject {
	NSMutableDictionary *settings;
}

+ (id)sharedInstance;
- (id)objectForKey:(NSString*)key;
- (void)setObject:(id)obj forKey:(NSString*)key;

- (NSString*)stringForKey:(NSString*)key;
- (void)setString:(NSString*)str forKey:(NSString*)key;

- (CGFloat)floatForKey:(NSString*)key;
- (void)setFloat:(CGFloat)value forKey:(NSString*)key;

- (NSInteger)integerForKey:(NSString*)key;
- (void)setInteger:(NSInteger)value forKey:(NSString*)key;

- (void)removeObjectForKey:(NSString*)key;
@end

