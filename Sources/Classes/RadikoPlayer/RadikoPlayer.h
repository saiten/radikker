//
//  RadikoPlayer.h
//  radikker
//
//  Created by saiten on 10/03/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "AuthClient.h"
#import "RTMPClient.h"
#import "FLVConverter.h"
#import "FileSave.h"
#import "AudioStreamPlayer.h"

typedef enum {
	RADIKOPLAYER_STATUS_AUTH,
	RADIKOPLAYER_STATUS_CONNECT,
	RADIKOPLAYER_STATUS_PLAY,
	RADIKOPLAYER_STATUS_DISCONNECT,
	RADIKOPLAYER_STATUS_STOP,
	RADIKOPLAYER_STATUS_FAILED,	
} RADIKOPLAYER_STATUS;

@interface RadikoPlayer : NSObject {
  BOOL authOnly;
	RADIKOPLAYER_STATUS status;

	AuthClient *authClient;
	RTMPClient *rtmpClient;
	FLVConverter *flvConverter;
	FileSave *fileSave;
	AudioStreamPlayer *audioStreamPlayer;
	
	NSPipe *rtmpToConvertPipe;
	NSPipe *convertToQueuePipe;
	
	NSString *channel;
	
	id delegate;
}

@property (nonatomic, readonly) RADIKOPLAYER_STATUS status;
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSString *channel;
@property (nonatomic, readonly) BOOL authOnly;
@property (nonatomic, readonly) NSString *areaCode;

- (void)authenticate;
- (void)play;
- (void)stop;
- (BOOL)isStop;

@end

@interface NSObject(RadikoPlayerDelegate)
- (void)radikoPlayerWillPlay:(RadikoPlayer*)radikoPlayer;
- (void)radikoPlayerWillStop:(RadikoPlayer*)radikoPlayer;
- (void)radikoPlayerDidPlay:(RadikoPlayer*)radikoPlayer;
- (void)radikoPlayerDidStop:(RadikoPlayer*)radikoPlayer;
- (void)radikoPlayerDidStartAuthentication:(RadikoPlayer*)radikoPlayer;
- (void)radikoPlayerDidFinishedAuthentication:(RadikoPlayer*)radikoPlayer;
- (void)radikoPlayerDidConnectRTMPStream:(RadikoPlayer*)radikoPlayer;
- (void)radikoPlayerDidDisconnectRTMPStream:(RadikoPlayer*)radikoPlayer;
- (void)radikoPlayerDidOpenAudioStream:(RadikoPlayer*)radikoPlayer;
- (void)radikoPlayerDidEmptyBuffer:(RadikoPlayer*)radikoPlayer;
- (void)radikoPlayerDidCloseAudioStream:(RadikoPlayer*)radikoPlayer;
- (void)radikoPlayerDidFailed:(RadikoPlayer*)radikoPlayer withError:(NSError*)error;
@end