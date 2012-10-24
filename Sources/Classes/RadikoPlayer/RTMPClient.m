//
//  RTMPClient.m
//  radikker
//
//  Created by saiten on 10/03/27.
//

#import "RTMPClient.h"

#define STR2AVAL(av, str)  av.av_val = (char*)str; av.av_len = strlen(av.av_val)

@implementation RTMPClient

@synthesize error, delegate, status;
@synthesize protocol, url, host, port;
@synthesize playPath, app, swfUrl, tcUrl, flashVersion;
@synthesize timeout, swfSize, bufferTime, seek, length;
@synthesize bufferSize;
@synthesize radikoAuthToken, radikoSwfUrl;

- (id)initWithDelegate:(id)aDelegate
{
	if((self =[super init])) {
		delegate = aDelegate;
		
		status = RTMPCLIENT_STATUS_INIT;
        
		swfSize = 0;
		seek = 0;
		length = 0;
		
		liveStream = YES;
		
		flashVersion = @"WIN 10,0,45,2";
        
		bufferTime = 10 * 60 * 60 * 1000;
		bufferSize = 16 * 1024;
	}
	return self;
}

- (void)connect
{
	if(status != RTMPCLIENT_STATUS_INIT)
		return;
    
	RTMP_ctrlC = NO;
	[NSThread detachNewThreadSelector:@selector(run:) toTarget:self withObject:self];
}

- (void)disconnect
{
	RTMP_ctrlC = true;
}

- (void)_setErrorWithErrorCode:(NSInteger)code message:(NSString*)message
{
	[error release];
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
	error = [[NSError alloc] initWithDomain:RTMPCLIENT_ERROR_DOMAIN
									   code:code
								   userInfo:userInfo];
}

- (RTMPCLIENT_STATUS)_getData
{
	int32_t now, lastUpdate;
    
	char *buffer = (char *) malloc(bufferSize);
	if(buffer == NULL) {
		[self _setErrorWithErrorCode:RTMPCLIENT_ERROR_UNKNOWN_CODE
                             message:@"failed to allocate memory."];
		return RTMPCLIENT_STATUS_FAILED;
	}
	
	int size = 0;
	int readSize = 0;
    
	rtmp.m_read.timestamp = seek;
    
	if (rtmp.m_read.timestamp)
		RTMP_Log(RTMP_LOGDEBUG, "Continuing at TS: %d ms\n", rtmp.m_read.timestamp);
	if (liveStream)
		RTMP_Log(RTMP_LOGDEBUG, "Starting Live Stream\n");
	if (length > 0)
		RTMP_Log(RTMP_LOGDEBUG, "For duration: %.3f sec\n", (double) length / 1000.0);
	
	now = RTMP_GetTime();
	lastUpdate = now - 1000;
	
	do {
		readSize = RTMP_Read(&rtmp, buffer, bufferSize);
        
		if (readSize > 0) {
			if(delegate && [delegate respondsToSelector:@selector(rtmpClient:receiveData:dataSize:)]) {
				[delegate rtmpClient:self receiveData:(const char*)buffer dataSize:readSize];
			}
			
			size += readSize;
			
			if (duration <= 0)
				duration = RTMP_GetDuration(&rtmp);
			
			if (duration > 0) {
				if (overrideBufferTime && bufferTime < (duration * 1000.0)) {
					bufferTime = (uint32_t) (duration * 1000.0) + 5000;   // extra 5sec to make sure we've got enough
					
					RTMP_Log(RTMP_LOGDEBUG,
                             "Detected that buffer time is less than duration, resetting to: %dms",
                             bufferTime);
					RTMP_SetBufferMS(&rtmp, bufferTime);
					RTMP_UpdateBufferMS(&rtmp);
                }
            }
        }
    } while (!RTMP_ctrlC && readSize > -1 && RTMP_IsConnected(&rtmp) && !RTMP_IsTimedout(&rtmp));
	
	free(buffer);
	
	if (readSize < 0)
		readSize = rtmp.m_read.status;
    
    if(readSize == -2)
        return RTMPCLIENT_STATUS_FAILED;
    
    if(readSize == -3)
        return RTMPCLIENT_STATUS_SUCCESS;
	
    if(readSize < 0 || RTMP_ctrlC || RTMP_IsTimedout(&rtmp))
        return RTMPCLIENT_STATUS_INCOMPLETE;
    else
        return RTMPCLIENT_STATUS_SUCCESS;
}

static const AVal av_conn = AVC("conn");

- (void)_connectStream
{
    AVal aHostName = { 0, 0 };
	AVal aPlayPath = { 0, 0 };
	AVal aTcUrl = { 0, 0 };
	AVal aPageUrl = { 0, 0 };
	AVal aApp = { 0, 0 };
	AVal aSwfUrl = { 0, 0 };
	AVal aFlashVer = { 0, 0 };
    AVal swfHash = { 0, 0 };
    AVal sockshost = { 0, 0 };
    
    unsigned char hash[RTMP_SWF_HASHLEN];
    uint32_t swfSize = 0;
    
    if(host) {
        STR2AVAL(aHostName, [host cStringUsingEncoding:NSASCIIStringEncoding]);
    }
	if(swfUrl) {
		STR2AVAL(aSwfUrl,   [swfUrl cStringUsingEncoding:NSASCIIStringEncoding]);
	}
	if(tcUrl) {
		STR2AVAL(aTcUrl,    [tcUrl cStringUsingEncoding:NSASCIIStringEncoding]);
	}
	if(pageUrl) {
		STR2AVAL(aPageUrl,  [pageUrl cStringUsingEncoding:NSASCIIStringEncoding]);
	}
	if(app) {
		STR2AVAL(aApp,      [app cStringUsingEncoding:NSASCIIStringEncoding]);
	}
	if(playPath) {
		STR2AVAL(aPlayPath, [playPath cStringUsingEncoding:NSASCIIStringEncoding]);
	}
	if(flashVersion) {
		STR2AVAL(aFlashVer, [flashVersion cStringUsingEncoding:NSASCIIStringEncoding]);
	}
    
	duration = 0.0;
	
    RTMP_LogSetLevel(RTMP_LOGDEBUG);
	RTMP_Init(&rtmp);
    
    if(radikoAuthToken) {
        AVal av1 = { 0, 0 };
        STR2AVAL(av1, [@"S:" cStringUsingEncoding:NSASCIIStringEncoding]);
        RTMP_SetOpt(&rtmp, &av_conn, &av1);
        AVal av2 = { 0, 0 };
        STR2AVAL(av2, [@"S:" cStringUsingEncoding:NSASCIIStringEncoding]);
        RTMP_SetOpt(&rtmp, &av_conn, &av2);
        AVal av3 = { 0, 0 };
        STR2AVAL(av3, [@"S:" cStringUsingEncoding:NSASCIIStringEncoding]);
        RTMP_SetOpt(&rtmp, &av_conn, &av3);
        AVal av4 = { 0, 0 };
        NSString *token = [NSString stringWithFormat:@"S:%@", radikoAuthToken];
        STR2AVAL(av4, [token cStringUsingEncoding:NSASCIIStringEncoding]);
        RTMP_SetOpt(&rtmp, &av_conn, &av4);
    }
    
    if(radikoSwfUrl) {
        if(RTMP_HashSWF([radikoSwfUrl cStringUsingEncoding:NSASCIIStringEncoding], &swfSize, hash, 30) == 0) {
            swfHash.av_val = (char*)hash;
            swfHash.av_len = RTMP_SWF_HASHLEN;
        }
    }
    
	RTMP_SetupStream(&rtmp, protocol, &aHostName, port, &sockshost, &aPlayPath,
					 &aTcUrl, &aSwfUrl, &aPageUrl, &aApp, NULL, &swfHash, swfSize,
					 &aFlashVer, NULL, NULL, seek, length, liveStream, timeout);
	
	BOOL first = YES;
	BOOL retries = NO;
    
	status = RTMPCLIENT_STATUS_CONNECT;
	while(!RTMP_ctrlC) {
        
		RTMP_SetBufferMS(&rtmp, bufferTime);
		
		if(first) {
			first = NO;
            
			DLog(@"RTMPClient Connecting");

			if (!RTMP_Connect(&rtmp, NULL)) {
				status = RTMPCLIENT_STATUS_FAILED;
				[self _setErrorWithErrorCode:RTMPCLIENT_ERROR_FAILED_CONNECT_CODE
                                     message:@"failed to connect server."];
				break;
            }
            
			if(delegate && [delegate respondsToSelector:@selector(rtmpClientDidOpenConnection:)]) {
				[delegate performSelector:@selector(rtmpClientDidOpenConnection:)
                                 onThread:[NSThread mainThread]
                               withObject:self
                            waitUntilDone:NO];
			}
			
			if (!RTMP_ConnectStream(&rtmp, seek)) {
				DLog(@"Failed to connect the stream");

				status = RTMPCLIENT_STATUS_FAILED;
				[self _setErrorWithErrorCode:RTMPCLIENT_ERROR_FAILED_CONNECTSTREAM_CODE
                                     message:@"failed to connect stream."];
				break;
            }
        } else {
			if (retries) {
				DLog(@"Failed to resume the stream");

				status = RTMPCLIENT_STATUS_FAILED;
				[self _setErrorWithErrorCode:RTMPCLIENT_ERROR_FAILED_RETRY_CODE
                                     message:@"connection timed out."];
				break;
            }
            
			DLog(@"Connection timed out, trying to resume.");
			if (rtmp.m_pausing == 3) {
				retries = YES;
				if (!RTMP_ReconnectStream(&rtmp, seek)) {
					DLog(@"Failed to resume the stream");
					status = RTMPCLIENT_STATUS_FAILED;
					[self _setErrorWithErrorCode:RTMPCLIENT_ERROR_FAILED_RECONNECTSTREAM_CODE
                                         message:@"failed to reconnect stream."];
					break;
                }
            } else if(!RTMP_ToggleStream(&rtmp)) {
				DLog(@"Failed to resume the stream");
				status = RTMPCLIENT_STATUS_FAILED;
				[self _setErrorWithErrorCode:RTMPCLIENT_ERROR_FAILED_TOGGLESTREAM_CODE
                                     message:@"failed to toggle stream."];
				break;
            }
        }
        
		status = [self _getData];
		DLog(@"status = %d, timed out = %d", status, RTMP_IsTimedout(&rtmp));
		if (status != RTMPCLIENT_STATUS_INCOMPLETE || !RTMP_IsTimedout(&rtmp))
			break;
	}
    
	if(status == RTMPCLIENT_STATUS_FAILED) {
		DLog(@"RTMPClient failed");
        
		if(delegate && [delegate respondsToSelector:@selector(rtmpClientDidFailed:)]) {
			[delegate performSelector:@selector(rtmpClientDidFailed:)
                             onThread:[NSThread mainThread]
                           withObject:self
                        waitUntilDone:NO];
		}
	}
    
	DLog(@"Closing connection.");
	RTMP_Close(&rtmp);
	
	if(delegate && [delegate respondsToSelector:@selector(rtmpClientDidCloseConnection:)]) {
		[delegate performSelector:@selector(rtmpClientDidCloseConnection:)
                         onThread:[NSThread mainThread]
                       withObject:self
                    waitUntilDone:NO];
	}
	
	status = RTMPCLIENT_STATUS_DISCONNECT;
}

- (void)run:(id)param
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	[self _connectStream];
	
	[pool release];
	[NSThread exit];
}

- (void)dealloc
{
	[error release];
    
	[url release];
	[host release];
	
	[playPath release];
	[app release];
	[tcUrl release];
	[pageUrl release];
	[flashVersion release];
	
	[swfUrl release];
    
	[super dealloc];
}

@end
