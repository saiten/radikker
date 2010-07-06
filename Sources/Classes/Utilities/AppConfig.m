
#import "AppConfig.h"

static AppConfig *_instance = nil;

@implementation AppConfig

+ (AppConfig*)sharedInstance
{
	if(_instance == nil) {
		_instance = [[AppConfig alloc] init];
	}
	return _instance;
}

- (id)init
{
	if(self = [super init]) {
		NSString *path = [[NSBundle mainBundle] pathForResource:@"AppConfig" ofType:@"plist"];
		[self loadConfigPlist:path];
	}
	return self;
}

- (void)loadConfigPlist:(NSString*)path
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	if(dict) {
		[configList release];
		configList = [dict retain];
	}
}

- (id)objectForKey:(id)key
{
	return [configList objectForKey:key];
}

@end
