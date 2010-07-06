

#import <Foundation/Foundation.h>

@interface AppConfig : NSObject {
	NSDictionary *configList;
}

+ (AppConfig*)sharedInstance;
- (void)loadConfigPlist:(NSString*)path;
- (id)objectForKey:(id)aKey;

@end
