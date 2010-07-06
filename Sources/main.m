//
//  main.m
//  radikker
//
//  Created by saiten on 10/03/15.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

void sig_pipe(int sig) 
{
	NSLog(@"catch SIGPIPE !!");
}

int main(int argc, char *argv[]) 
{
	// ('A`) < iphone can not catch signal ..
	//signal(SIGPIPE, sig_pipe);
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"RDIPAppDelegate");
    [pool release];

    return retVal;
}
