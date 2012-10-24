//
//  main.m
//  radikker
//
//  Created by saiten on 10/03/15.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) 
{
	signal(SIGPIPE, SIG_IGN);
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"RDIPAppDelegate");
    [pool release];

    return retVal;
}
