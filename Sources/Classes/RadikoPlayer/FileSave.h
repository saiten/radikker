//
//  FileSave.h
//  radikker
//
//  Created by saiten on 10/03/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FileSave : NSObject {
	BOOL active;
	
	NSFileHandle *inputHandle;
	NSFileHandle *outputHandle;
}

@property (nonatomic, retain) NSFileHandle *inputHandle;

- (id)initWithSaveFileAtPath:(NSString*)path;
- (void)save;

@end
