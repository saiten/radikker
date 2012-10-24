//
//  FileSave.m
//  radikker
//
//  Created by saiten on 10/03/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FileSave.h"


@implementation FileSave

@synthesize inputHandle;

- (id)initWithSaveFileAtPath:(NSString *)path
{
	if((self = [super init])) {
		[[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
		outputHandle = [NSFileHandle fileHandleForWritingAtPath:path];
		[outputHandle retain];
		active = NO;
	}
	return self;
}

- (void)save
{
	if(active)
		return;
	
	active = YES;
	[NSThread detachNewThreadSelector:@selector(run:) toTarget:self withObject:self];
}

- (void)run:(id)param
{
	DLog(@"FileSave start.");
	
	if(inputHandle == nil) {
		DLog(@"FileSave inputHandle closed.");
		return;
	}
	
	int fh = [inputHandle fileDescriptor];
	int ofh = [outputHandle fileDescriptor];
	
	int size = 0;
	char buf[1024];
	while((size = read(fh, buf, 1024)) > 0) {
		DLog(@"FileSave saveBuf : %d", size);
		write(ofh, buf, size);
	}
    
	[inputHandle closeFile];
	[outputHandle closeFile];
	
	active = NO;
    
	DLog(@"FileSave end.");
}

- (void)dealloc
{
	[inputHandle release];
	[outputHandle release];
	[super dealloc];
}

@end
