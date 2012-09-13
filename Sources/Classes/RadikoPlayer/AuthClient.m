//
//  AuthClient.m
//  radikker
//
//  Created by saiten on 11/05/26.
//  Copyright 2011 iside. All rights reserved.
//

#import "AuthClient.h"
#import "AppConfig.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "swftools/rfxswf.h"
#import "RegexKitLite.h"

// extract binary from swf
void extract_id(const void *data, int len, int extract_id, void **extract_data, int *extract_len)
{
  SWF swf;
  reader_t r;
  int dx = 6; // offset to binary data
  
  reader_init_memreader(&r, data, len);
  if(swf_ReadSWF2(&r, &swf) < 0) {
    *extract_data = NULL;
    *extract_len = -1;
    return;
  }
  
  TAG *tag = swf.firstTag;
  while(tag) {
    if(swf_isDefiningTag(tag)) {
      int _id = swf_GetDefineID(tag);
      if(_id == extract_id && tag->id == ST_DEFINEBINARY) {
        int _len = tag->memsize - dx;
        void* _p = (void*)malloc(_len);
        if (_p == NULL)
          return;
        memcpy(_p, tag->data+dx, _len);
        
        *extract_data = _p;
        *extract_len = _len;
        return;
      }
    }
    tag = tag->next;
  }
}

@interface AuthClient (private)
- (void)_getPlayer;
- (BOOL)_extractAuthTokenWithData:(NSData*)data;
- (void)_challengeFirstAuthentication;
- (void)_challengeSecondAuthentication;
- (void)_failed:(NSError*)error;
@end

@implementation AuthClient

@synthesize authToken, partialKey, areaCode, state, lastAuthDate, error;

- (id)initWithDelegate:(id)aDelegate
{
  if ((self = [super init])) {    
    state = AuthClientStateInit;
    delegate = aDelegate;
  }
  return self;
}

- (void)dealloc
{
  [keyData release];
  [authToken release];
  [partialKey release];
  [lastAuthDate release];
  [super dealloc];
}

# pragma mark -
# pragma mark Public APIs

- (void)startAuthentication
{
  if(!(state == AuthClientStateInit || state == AuthClientStateFailed))
    return;
  
  lastAuthDate = [[NSDate date] retain];
  
  [self _getPlayer];  
}

- (void)cancel
{
  //[request cancel];
}

#pragma mark -
#pragma mark Private APIs


- (void)_getPlayer
{
  state = AuthClientStateGetPlayer;
  
	NSDictionary *dic = [[AppConfig sharedInstance] objectForKey:@"RadikoPlayer"];
  NSURL *url = [NSURL URLWithString:[dic objectForKey:@"SwfUrl"]];
  
  __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
  [request setDownloadCache:[ASIDownloadCache sharedCache]];
  [request setCachePolicy:ASIUseDefaultCachePolicy];
  [request setUserAgent:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/534.55.3 (KHTML, like Gecko) Version/5.1.3 Safari/534.53.10"];
    
  [request setCompletionBlock:^{
    NSData *data = [request responseData];
    if([self _extractAuthTokenWithData:data])
      [self _challengeFirstAuthentication];
    else
      [self _failed:nil];
  }];
  [request setFailedBlock:^{
    [self _failed:request.error];
  }];  
  [request startAsynchronous];
  
  if(delegate && [delegate respondsToSelector:@selector(authClient:didChangeState:)])
    [delegate authClient:self didChangeState:state];
}

- (BOOL)_extractAuthTokenWithData:(NSData*)swfData
{
  int keyId = 5;
  void *data = NULL;
  int len = 0;
  
  extract_id([swfData bytes], [swfData length], keyId, &data, &len);
  if(data == NULL) {
    return NO;
  } else {
    keyData = [[NSData alloc] initWithBytesNoCopy:data length:len freeWhenDone:YES];
    return YES;
  }  
}

-(void)_challengeFirstAuthentication
{
  state = AuthClientStateAuth1;
	NSDictionary *dic = [[AppConfig sharedInstance] objectForKey:@"RadikoPlayer"];
  NSURL *url = [NSURL URLWithString:[dic objectForKey:@"Auth1Url"]];

  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [headers setValue:@"pc_1"        forKey:@"X-Radiko-App"];
  [headers setValue:@"2.0.1"       forKey:@"X-Radiko-App-Version"];
  [headers setValue:@"test-stream" forKey:@"X-Radiko-User"];
  [headers setValue:@"pc"          forKey:@"X-Radiko-Device"];
  
  __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
  [request setRequestMethod:@"POST"];
  [request setRequestHeaders:headers];
  [request setValidatesSecureCertificate:NO];
  [request appendPostData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  
  [request setCompletionBlock:^{
    NSDictionary *responseHeaders = [request responseHeaders];
    authToken = [[responseHeaders objectForKey:@"X-Radiko-Authtoken"] retain];
    offset = [[responseHeaders objectForKey:@"X-Radiko-Keyoffset"] intValue];
    length = [[responseHeaders objectForKey:@"X-Radiko-Keylength"] intValue];
    
    NSRange range = NSMakeRange(offset, length);
    NSData *partialData = [keyData subdataWithRange:range];
    partialKey = [[ASIHTTPRequest base64forData:partialData] retain];
    
    if(authToken && partialKey)
      [self _challengeSecondAuthentication];
    else
      [self _failed:nil];
  }];
  [request setFailedBlock:^{
    [self _failed:request.error];
  }];  
  [request startAsynchronous];

  if(delegate && [delegate respondsToSelector:@selector(authClient:didChangeState:)])
    [delegate authClient:self didChangeState:state];
}

- (void)_challengeSecondAuthentication
{
  state = AuthClientStateAuth2;
  
	NSDictionary *dic = [[AppConfig sharedInstance] objectForKey:@"RadikoPlayer"];
  NSURL *url = [NSURL URLWithString:[dic objectForKey:@"Auth2Url"]];
  
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [headers setValue:@"pc_1"        forKey:@"X-Radiko-App"];
  [headers setValue:@"2.0.1"       forKey:@"X-Radiko-App-Version"];
  [headers setValue:@"test-stream" forKey:@"X-Radiko-User"];
  [headers setValue:@"pc"          forKey:@"X-Radiko-Device"];
  [headers setValue:authToken      forKey:@"X-Radiko-Authtoken"];
  [headers setValue:partialKey     forKey:@"X-Radiko-Partialkey"];
    
  __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
  [request setRequestMethod:@"POST"];
  [request setRequestHeaders:headers];
  [request setValidatesSecureCertificate:NO];
  [request appendPostData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  [request setCompletionBlock:^{
    state = AuthClientStateSuccess;

    NSString *body = [request responseString];
    areaCode = [[body stringByMatching:@"\\n(JP\\d+)," capture:1L] retain];
    
    if(delegate && [delegate respondsToSelector:@selector(authClient:didChangeState:)])
      [delegate authClient:self didChangeState:state];    
  }];
  [request setFailedBlock:^{
    [self _failed:request.error];
  }];  
  [request startAsynchronous];
  
  if(delegate && [delegate respondsToSelector:@selector(authClient:didChangeState:)])
    [delegate authClient:self didChangeState:state];  
}

- (void)_failed:(NSError *)_error
{
  state = AuthClientStateFailed;
  [error release];
  error = [_error retain];
  
  if(delegate && [delegate respondsToSelector:@selector(authClient:didChangeState:)])
    [delegate authClient:self didChangeState:state];
}

@end
