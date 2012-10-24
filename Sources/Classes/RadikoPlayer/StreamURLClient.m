//
//  StreamURLClient.m
//  radikker
//
//  Created by saiten on 12/10/24.
//
//

#import "StreamURLClient.h"
#import "ASIHTTPRequest.h"
#import "AppConfig.h"
#import "RDIPDefines.h"
#import "GDataXMLNodeUtil.h"

@implementation StreamURLClient
@synthesize delegate=_delegate;

- (id)initWithDelegate:(id)delegate
{
    self = [super init];
    if(self) {
        self.delegate = delegate;
    }
    return self;
}

- (NSURL*)_parseXML:(NSData*)xmlData
{
    NSError *error = nil;
	GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error] autorelease];
	if(error) {
		return nil;
    }
	
	GDataXMLNode *rootNode = [document rootElement];
	NSString *streamURL = [[rootNode nodeForXPath:@"//url/item[1]" error:&error] stringValue];
    if(streamURL) {
        return [NSURL URLWithString:streamURL];
    } else {
        return nil;
    }
}

- (void)loadStreamURLWithChannel:(NSString*)channel
{
	NSDictionary *dic = [[AppConfig sharedInstance] objectForKey:@"RadikoPlayer"];
    NSURL *streamListURL = [NSURL URLWithString:[NSString stringWithFormat:[dic objectForKey:@"StreamListUrl"], channel]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:streamListURL];
    [request setUserAgent:RDIP_FAKE_USERAGENT];
    
    [request setCompletionBlock:^{
        NSData *xmlData = [request responseData];
        NSURL *streamURL = [self _parseXML:xmlData];
        if(streamURL) {
            if(self.delegate && [self.delegate respondsToSelector:@selector(streamURLClient:didReceiveStreamURL:)]) {
                [self.delegate streamURLClient:self didReceiveStreamURL:streamURL];
            } else if(self.delegate && [self.delegate respondsToSelector:@selector(streamURLClient:didFailWithError:)]) {
                [self.delegate streamURLClient:self didFailWithError:nil];
            }
        }
    }];
    
    [request setFailedBlock:^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(streamURLClient:didFailWithError:)]) {
            [self.delegate streamURLClient:self didFailWithError:request.error];
        }
    }];
    
    [request startAsynchronous];
}

@end
