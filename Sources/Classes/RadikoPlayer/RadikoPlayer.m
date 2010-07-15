//
//  RadikoPlayer.m
//  radikker
//
//  Created by saiten on 10/03/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppSetting.h"
#import "AppConfig.h"
#import "RDIPDefines.h"
#import "RadikoPlayer.h"

@implementation RadikoPlayer

@synthesize status, channel, delegate;

- (id)init
{
	if((self = [super init])) {
		status = RADIKOPLAYER_STATUS_STOP;
	}
	return self;
}

- (void)_connectRadiko
{
	NSDictionary *dic = [[AppConfig sharedInstance] objectForKey:@"RadikoPlayer"];
	
	rtmpClient = [[RTMPClient alloc] initWithDelegate:self];
	
	NSString *protocol     = [dic objectForKey:@"Protocol"];
	NSString *hostName     = [dic objectForKey:@"HostName"];
	int port               = [[dic objectForKey:@"Port"] intValue];
	NSString *playPath     = [dic objectForKey:@"PlayPath"];
	NSString *swfUrl       = [dic objectForKey:@"SwfUrl"];
	NSString *flashVersion = [dic objectForKey:@"FlashVersion"];
	
	NSString *appFormat    = [dic objectForKey:@"AppFormat"];
	NSString *app = [NSString stringWithFormat:appFormat, channel];
	
	NSString *url = [NSString stringWithFormat:@"%@://%@:%d/%@/%@", protocol, hostName, port, app, playPath];

	if([protocol isEqual:@"rtmp"])
		rtmpClient.protocol = RTMP_PROTOCOL_RTMP;
	else if([protocol isEqual:@"rtmpe"])
		rtmpClient.protocol = RTMP_PROTOCOL_RTMPE;
	else if([protocol isEqual:@"rtmps"])
		rtmpClient.protocol = RTMP_PROTOCOL_RTMPS;
	else if([protocol isEqual:@"rtmpt"])
		rtmpClient.protocol = RTMP_PROTOCOL_RTMPT;
	else if([protocol isEqual:@"rtmpte"])
		rtmpClient.protocol = RTMP_PROTOCOL_RTMPTE;
	else
		rtmpClient.protocol = RTMP_PROTOCOL_UNDEFINED;

	rtmpClient.host = hostName;
	rtmpClient.port = port;
	rtmpClient.playPath = playPath;
	rtmpClient.app = app;
	rtmpClient.tcUrl = url;
	rtmpClient.url = url;
	rtmpClient.swfUrl = swfUrl;
	rtmpClient.flashVersion = flashVersion;
	rtmpClient.timeout = 15;
	
	[rtmpClient connect];
}

- (void)_relayConverter
{
	flvConverter = [[FLVConverter alloc] initWithFileHandle:[rtmpToConvertPipe fileHandleForReading]];
	flvConverter.delegate = self;
	[flvConverter convertToFileHandle:[convertToQueuePipe fileHandleForWriting]];
}

- (void)_saveTemporaryFile
{
	NSString *path = [NSHomeDirectory() stringByAppendingString:@"/dump.aac"];
	fileSave = [[FileSave alloc] initWithSaveFileAtPath:path];
	fileSave.inputHandle = [convertToQueuePipe fileHandleForReading];
	[fileSave save];
}

- (void)_createAudioFileStream
{
	NSNumber *numBufferSize = [[AppSetting sharedInstance] objectForKey:RDIPSETTING_BUFFERSIZE];
	
	audioStreamPlayer = [[AudioStreamPlayer alloc] initWithDelegate:self bufferSize:[numBufferSize intValue]];
	audioStreamPlayer.inputHandle = [convertToQueuePipe fileHandleForReading];
	
	[audioStreamPlayer play];
}

- (void)play
{
	@synchronized(self) {
		if(status == RADIKOPLAYER_STATUS_PLAY || 
		   status == RADIKOPLAYER_STATUS_CONNECT ||
		   status == RADIKOPLAYER_STATUS_DISCONNECT)
			return;	

		status = RADIKOPLAYER_STATUS_CONNECT;

		if(delegate && [delegate respondsToSelector:@selector(radikoPlayerWillPlay:)])
			[delegate radikoPlayerWillPlay:self];
		
		rtmpToConvertPipe = [[NSPipe pipe] retain];
		convertToQueuePipe = [[NSPipe pipe] retain];
	
		[self _connectRadiko];
	}
}

- (void)stop
{
	@synchronized(self) {
		if(!(status == RADIKOPLAYER_STATUS_PLAY ||
			 status == RADIKOPLAYER_STATUS_CONNECT ||
			 status == RADIKOPLAYER_STATUS_DISCONNECT))
			return;

		status = RADIKOPLAYER_STATUS_DISCONNECT;

		if(delegate && [delegate respondsToSelector:@selector(radikoPlayerWillStop:)])
			[delegate radikoPlayerWillStop:self];
		
		[rtmpClient disconnect];
		[audioStreamPlayer stop];
	}
}

- (void)_completeStop
{	
	status = RADIKOPLAYER_STATUS_STOP;
	if(delegate && [delegate respondsToSelector:@selector(radikoPlayerDidStop:)]) {
		[delegate radikoPlayerDidStop:self];
	}
}

- (BOOL)isStop
{
	return (rtmpClient == nil) && (flvConverter == nil) && (audioStreamPlayer == nil);
}

#pragma mark -
#pragma mark RTMPClient delegate methods

- (void)rtmpClientDidOpenConnection:(RTMPClient*)client
{
	if(delegate && [delegate respondsToSelector:@selector(radikoPlayerDidConnectRTMPStream:)])
		[delegate radikoPlayerDidConnectRTMPStream:self];

	[self _relayConverter];
}

- (void)rtmpClientDidCloseConnection:(RTMPClient*)client
{
	@synchronized(self) {
		NSLog(@"rtmpClientDidCliseConnection");
		[[rtmpToConvertPipe fileHandleForWriting] closeFile];

		[rtmpClient autorelease];
		rtmpClient = nil;
		
		if(delegate && [delegate respondsToSelector:@selector(radikoPlayerDidDisconnectRTMPStream:)])
			[delegate radikoPlayerDidDisconnectRTMPStream:self];		
	}
}

- (void)rtmpClient:(RTMPClient*)client receiveData:(const char *)data dataSize:(int)size
{
	NSFileHandle *handle = [rtmpToConvertPipe fileHandleForWriting];
	NSData *writeData = [[NSData alloc] initWithBytes:data length:size];
	[handle writeData:writeData];
	[writeData release];
}

- (void)rtmpClientDidFailed:(RTMPClient*)client
{
	if(delegate && [delegate respondsToSelector:@selector(radikoPlayerDidFailed:withError:)])
		[delegate radikoPlayerDidFailed:self withError:client.error];

	[self rtmpClientDidCloseConnection:client];
}

#pragma mark -
#pragma mark FLVConverter delegate methods

- (void)flvConverterDidStartConvert:(FLVConverter *)converter
{
	//[self _saveTemporaryFile];
	[self _createAudioFileStream];
}

- (void)flvConverterDidFailed:(FLVConverter *)converter
{
	[self flvConverterDidFinishConvert:converter];
}

- (void)flvConverterDidFinishConvert:(FLVConverter *)converter
{
	@synchronized(self) {
		NSLog(@"flvConverterDidFinishConvert");
		[[rtmpToConvertPipe fileHandleForReading] closeFile];
		[rtmpToConvertPipe release];
		rtmpToConvertPipe = nil;
		[[convertToQueuePipe fileHandleForWriting] closeFile];
		
		[flvConverter autorelease];
		flvConverter = nil;
	}
}

#pragma mark -
#pragma mark AudioStreamPlayer delegate methods

- (void)audioStreamPlayerDidPlay:(AudioStreamPlayer *)player
{
	if(delegate && [delegate respondsToSelector:@selector(radikoPlayerDidOpenAudioStream:)])
		[delegate radikoPlayerDidOpenAudioStream:self];

	status = RADIKOPLAYER_STATUS_PLAY;
	if(delegate && [delegate respondsToSelector:@selector(radikoPlayerDidPlay:)]) {
		[delegate radikoPlayerDidPlay:self];
	}
}

- (void)audioStreamPlayerDidBufferEmpty:(AudioStreamPlayer *)player
{
	if(delegate && [delegate respondsToSelector:@selector(radikoPlayerDidEmptyBuffer:)])
		[delegate radikoPlayerDidEmptyBuffer:self];
}

- (void)audioStreamPlayerDidStop:(AudioStreamPlayer *)player
{
	@synchronized(self) {
		NSLog(@"audioStreamPlayerDidStop");
		[[convertToQueuePipe fileHandleForReading] closeFile];
		[convertToQueuePipe release];
		convertToQueuePipe = nil;

		[audioStreamPlayer autorelease];
		audioStreamPlayer = nil;

		if(delegate && [delegate respondsToSelector:@selector(radikoPlayerDidCloseAudioStream:)])
			[delegate radikoPlayerDidCloseAudioStream:self];

		[self _completeStop];
	}
}

@end
