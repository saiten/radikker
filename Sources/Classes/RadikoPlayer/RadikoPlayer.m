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
#import "AuthClient.h"
#import "NetworkInformation.h"

@implementation RadikoPlayer

@synthesize status, channel, delegate, authOnly, service;

- (id)init
{
	if((self = [super init])) {
        service = RADIKOPLAYER_SERVICE_RADIKO;
		status = RADIKOPLAYER_STATUS_STOP;
        bgTask = UIBackgroundTaskInvalid;
	}
	return self;
}

- (void)_beginBackgroundTask
{
    UIApplication *app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}

- (void)_endBackgroundTask
{
    if(bgTask != UIBackgroundTaskInvalid) {
        UIApplication *app = [UIApplication sharedApplication];
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }
}

- (void)_authentication
{
    [authClient release];
    authClient = [[AuthClient alloc] initWithDelegate:self];
    [authClient startAuthentication];
}

- (void)_loadStreamInformation
{
    
}

- (void)_connectStreamWithSetting:(NSDictionary*)setting
{
	rtmpClient = [[RTMPClient alloc] initWithDelegate:self];
	
	NSString *protocol     = [setting objectForKey:@"Protocol"];
	NSString *hostName     = [setting objectForKey:@"HostName"];
	int port               = [[setting objectForKey:@"Port"] intValue];
	NSString *playPath     = [setting objectForKey:@"PlayPath"];
	NSString *swfUrl       = [setting objectForKey:@"SwfUrl"];
	NSString *flashVersion = [setting objectForKey:@"FlashVersion"];
    NSString *app          = [setting objectForKey:@"App"];
	
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
    rtmpClient.radikoAuthToken = authClient.authToken;
    rtmpClient.radikoSwfUrl = swfUrl;
	
	[rtmpClient connect];
}

- (void)_connectRadiru
{
    NSString *settingName = [NSString stringWithFormat:@"RadiruPlayer_%@", channel];
 	NSDictionary *setting = [[AppConfig sharedInstance] objectForKey:settingName];
    [self _connectStreamWithSetting:setting];
}

- (void)_connectRadiko
{
    status = RADIKOPLAYER_STATUS_LOADSTREAMINFO;
    StreamURLClient *streamURLClient = [[StreamURLClient alloc] initWithDelegate:self];
    [streamURLClient loadStreamURLWithChannel:channel];
}

- (void)_relayConverter
{
	flvConverter = [[FLVConverter alloc] initWithFileHandle:[rtmpToConvertPipe fileHandleForReading]];
	flvConverter.delegate = self;
	[flvConverter convertToFileHandle:[convertToQueuePipe fileHandleForWriting]];
}

- (void)_saveTemporaryFile
{
	NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Documents/dump.aac"];
	fileSave = [[FileSave alloc] initWithSaveFileAtPath:path];
	fileSave.inputHandle = [convertToQueuePipe fileHandleForReading];
	[fileSave save];
}

- (void)_createAudioFileStream
{
	NSNumber *numBufferSize = [[AppSetting sharedInstance] objectForKey:RDIPSETTING_BUFFERSIZE];
	
	audioStreamPlayer = [[AudioStreamPlayer alloc] initWithDelegate:self bufferSize:[numBufferSize intValue]];
	audioStreamPlayer.inputHandle = [convertToQueuePipe fileHandleForReading];
    
    if(service == RADIKOPLAYER_SERVICE_RADIKO)
        audioStreamPlayer.volume = 0.5;
    else
        audioStreamPlayer.volume = 0.5;
	
	[audioStreamPlayer play];
}

- (void)authenticate
{
    @synchronized(self) {
		if(status == RADIKOPLAYER_STATUS_AUTH ||
           status == RADIKOPLAYER_STATUS_LOADSTREAMINFO ||
           status == RADIKOPLAYER_STATUS_PLAY ||
		   status == RADIKOPLAYER_STATUS_CONNECT ||
		   status == RADIKOPLAYER_STATUS_DISCONNECT)
			return;
        
		status = RADIKOPLAYER_STATUS_AUTH;
        authOnly = YES;
        
        if(authClient.state != AuthClientStateSuccess)
            [self _authentication];
    }
}

- (void)play
{
	@synchronized(self) {
		if(status == RADIKOPLAYER_STATUS_AUTH ||
           status == RADIKOPLAYER_STATUS_LOADSTREAMINFO ||
           status == RADIKOPLAYER_STATUS_PLAY ||
		   status == RADIKOPLAYER_STATUS_CONNECT ||
		   status == RADIKOPLAYER_STATUS_DISCONNECT)
			return;
        
        [self _beginBackgroundTask];
        
		status = RADIKOPLAYER_STATUS_AUTH;
        authOnly = NO;
        
		if(delegate && [delegate respondsToSelector:@selector(radikoPlayerWillPlay:)])
			[delegate radikoPlayerWillPlay:self];
		
		rtmpToConvertPipe = [[NSPipe pipe] retain];
		convertToQueuePipe = [[NSPipe pipe] retain];
        
        if(service == RADIKOPLAYER_SERVICE_RADIKO) {
            
            NSTimeInterval interval = fabs([authClient.lastAuthDate timeIntervalSinceNow]);
            DLog(@"last auth date = %.1f", interval);
            
            if(authClient.state == AuthClientStateSuccess && interval < 600.0)
                [self _connectRadiko];
            else
                [self _authentication];
        } else if(service == RADIKOPLAYER_SERVICE_RADIRU) {
            [self _connectRadiru];
        }
        
	}
}

- (void)stop
{
	@synchronized(self) {
		if(!(status == RADIKOPLAYER_STATUS_PLAY ||
             status == RADIKOPLAYER_STATUS_AUTH ||
             status == RADIKOPLAYER_STATUS_LOADSTREAMINFO ||
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

- (NSString*)areaCode
{
    return authClient.areaCode;
}

#pragma mark -
#pragma mark AuthClient delegate methods

- (void)authClient:(AuthClient *)client didChangeState:(AuthClientState)state
{
    if(state == AuthClientStateGetPlayer) {
        if (delegate && [delegate respondsToSelector:@selector(radikoPlayerDidStartAuthentication:)])
            [delegate radikoPlayerDidStartAuthentication:self];
    } else if(state == AuthClientStateSuccess) {
        if (delegate && [delegate respondsToSelector:@selector(radikoPlayerDidFinishedAuthentication:)])
            [delegate radikoPlayerDidFinishedAuthentication:self];
        
        if(!authOnly)
            [self _connectRadiko];
        else
            status = RADIKOPLAYER_STATUS_STOP;
    } else if(client.error) {
        if(delegate && [delegate respondsToSelector:@selector(radikoPlayerDidFailed:withError:)])
            [delegate radikoPlayerDidFailed:self withError:client.error];
        status = RADIKOPLAYER_STATUS_STOP;
        [self _endBackgroundTask];
    }
}

#pragma mark -
#pragma mark StreamURLClient delegate methods

- (void)streamURLClient:(StreamURLClient *)client didReceiveStreamURL:(NSURL *)streamURL
{
    NSDictionary *baseSetting = [[AppConfig sharedInstance] objectForKey:@"RadikoPlayer"];
    NSMutableDictionary *setting = [NSMutableDictionary dictionaryWithDictionary:baseSetting];
    
    [setting setObject:streamURL.scheme forKey:@"Protocol"];
    [setting setObject:streamURL.host forKey:@"HostName"];
    
    NSArray *appComponents = [streamURL.pathComponents subarrayWithRange:NSMakeRange(1, streamURL.pathComponents.count-2)];
    NSString *app = [appComponents componentsJoinedByString:@"/"];
    [setting setObject:app forKey:@"App"];
    
    NSString *playPath = [streamURL.pathComponents lastObject];
    [setting setObject:playPath forKey:@"PlayPath"];
    
    if(streamURL.port) {
        [setting setObject:streamURL.port forKey:@"Port"];
    }
    
    [self _connectStreamWithSetting:setting];
}

- (void)streamURLClient:(StreamURLClient *)client didFailWithError:(NSError *)error
{
    if(delegate && [delegate respondsToSelector:@selector(radikoPlayerDidFailed:withError:)]) {
        [delegate radikoPlayerDidFailed:self withError:error];
    }
    status = RADIKOPLAYER_STATUS_STOP;
    [self _endBackgroundTask];
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
		DLog(@"rtmpClientDidCliseConnection");
        
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
    
    [self _endBackgroundTask];
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
		DLog(@"flvConverterDidFinishConvert");

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
    
    [self _endBackgroundTask];
}

- (void)audioStreamPlayerDidBufferEmpty:(AudioStreamPlayer *)player
{
	if(delegate && [delegate respondsToSelector:@selector(radikoPlayerDidEmptyBuffer:)])
		[delegate radikoPlayerDidEmptyBuffer:self];
}

- (void)audioStreamPlayerDidStop:(AudioStreamPlayer *)player
{
	@synchronized(self) {
		DLog(@"audioStreamPlayerDidStop");

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
