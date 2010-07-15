//
//  RTMPClient.h
//  radikker
//
//  Created by saiten on 10/03/27.
//

#import <Foundation/Foundation.h>
#import "log.h"
#import "rtmp.h"

#define RTMPCLIENT_ERROR_DOMAIN @"net.isidesystem.RTMPClientErrorDomain"
#define RTMPCLIENT_ERROR_FAILED_CONNECT_CODE         100
#define RTMPCLIENT_ERROR_FAILED_CONNECTSTREAM_CODE   101
#define RTMPCLIENT_ERROR_FAILED_RECONNECTSTREAM_CODE 102
#define RTMPCLIENT_ERROR_FAILED_RETRY_CODE           103
#define RTMPCLIENT_ERROR_FAILED_TOGGLESTREAM_CODE    104
#define RTMPCLIENT_ERROR_UNKNOWN_CODE                105

typedef enum {
	RTMPCLIENT_STATUS_INIT,
	RTMPCLIENT_STATUS_CONNECT,
	RTMPCLIENT_STATUS_INCOMPLETE,
	RTMPCLIENT_STATUS_SUCCESS,
	RTMPCLIENT_STATUS_FAILED,
	RTMPCLIENT_STATUS_DISCONNECT,
} RTMPCLIENT_STATUS;

@interface RTMPClient : NSObject {
	id delegate;
	NSError *error;
	
	RTMP rtmp;
	RTMPCLIENT_STATUS status;

	NSString *url;

	int protocol;
	NSString *host;
	int port;
	
	NSString *playPath;
	NSString *app;
	NSString *tcUrl;
	NSString *pageUrl;
	NSString *flashVersion;

	NSString *swfUrl;
	uint32_t swfSize;

	BOOL liveStream;
	long int timeout;

	BOOL overrideBufferTime;
	uint32_t bufferTime;
	uint32_t seek;
	uint32_t length;
	
	double duration;
	
	uint32_t bufferSize;
}

@property(nonatomic, assign) id delegate;
@property(nonatomic, readonly) RTMPCLIENT_STATUS status;
@property(nonatomic, readwrite) int protocol, port;
@property(nonatomic, readwrite) long int timeout;
@property(nonatomic, retain) NSString *url, *host, *playPath, *app, *swfUrl, *tcUrl, *flashVersion;
@property(nonatomic, readwrite) uint32_t swfSize, bufferTime, seek, length, bufferSize;
@property(nonatomic, readonly) NSError *error;

- (id)initWithDelegate:(id)delegate;
- (void)connect;
- (void)disconnect;

@end

@interface NSObject (RTMPClientDelegate)
- (void)rtmpClient:(RTMPClient*)client receiveData:(const char *)data dataSize:(int)size;
- (void)rtmpClientDidOpenConnection:(RTMPClient*)client;
- (void)rtmpClientDidCloseConnection:(RTMPClient*)client;
- (void)rtmpClientDidFailed:(RTMPClient*)client;
@end

