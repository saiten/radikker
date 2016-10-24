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
#import "RegexKitLite.h"
#import "RDIPDefines.h"
#import "SwiffParser.h"
#import "SwiffUtils.h"

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
    int keyId = [[dic objectForKey:@"ExtractKeyId"] intValue];
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDownloadCache:[ASIDownloadCache sharedCache]];
    [request setCachePolicy:ASIUseDefaultCachePolicy];
    [request setUserAgent:RDIP_FAKE_USERAGENT];
    
    [request setCompletionBlock:^{
        NSData *data = [request responseData];
        if([self _extractAuthTokenWithData:data keyId:keyId])
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

- (BOOL)_extractAuthTokenWithData:(NSData*)swfData keyId:(int)keyId
{
    SwiffParser *parser = SwiffParserCreate([swfData bytes], swfData.length);
    
    SwiffHeader header;
    SwiffParserReadHeader(parser, &header);
    if(header.version < 6) {
        SwiffParserSetStringEncoding(parser, SwiffGetLegacyStringEncoding());
    }
    
    BOOL result = NO;
    
    while(SwiffParserIsValid(parser)) {
        SwiffParserAdvanceToNextTag(parser);
        
        SwiffTag tag = SwiffParserGetCurrentTag(parser);
        if(tag == SwiffTagEnd) {
            break;
        }
        
        if(tag == SwiffTagDefineBinaryData) {
            UInt16 definitionId;
            SwiffParserReadUInt16(parser, &definitionId);
            if(definitionId == keyId) {
                UInt32 reserved;
                SwiffParserReadUInt32(parser, &reserved);
                
                NSUInteger remainLength = SwiffParserGetBytesRemainingInCurrentTag(parser);
                NSData *data = nil;
                SwiffParserReadData(parser, remainLength, &data);
                keyData = [data retain];
                result = YES;
                break;
            }
        }
    }
    
    SwiffParserFree(parser);
    return result;
}

-(void)_challengeFirstAuthentication
{
    state = AuthClientStateAuth1;
	NSDictionary *dic = [[AppConfig sharedInstance] objectForKey:@"RadikoPlayer"];
    NSURL *url = [NSURL URLWithString:[dic objectForKey:@"Auth1Url"]];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [headers setValue:@"pc_ts"       forKey:@"X-Radiko-App"];
    [headers setValue:@"4.0.0"       forKey:@"X-Radiko-App-Version"];
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
    [headers setValue:@"pc_ts"       forKey:@"X-Radiko-App"];
    [headers setValue:@"4.0.0"       forKey:@"X-Radiko-App-Version"];
    [headers setValue:@"test-stream" forKey:@"X-Radiko-User"];
    [headers setValue:@"pc"          forKey:@"X-Radiko-Device"];
    [headers setValue:authToken      forKey:@"X-Radiko-AuthToken"];
    [headers setValue:partialKey     forKey:@"X-Radiko-PartialKey"];
    
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
