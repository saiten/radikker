//
//  SharedImageStore.h
//  radikker
//
//  Created by saiten on 10/03/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageStore.h"

#define SHAREDIMAGESTORE_GETNEWIMAGE_NOTIFICATION @"SharedImageStoreGetNewImageNotification"
#define SHAREDIMAGESTORE_KEY_REQUESTURL @"RequestURL"

@interface SharedImageStore : NSObject {
	ImageStore *imageStore;
}

+ (id)sharedInstance;
- (UIImage*)getImage:(NSString*)url;

@end

