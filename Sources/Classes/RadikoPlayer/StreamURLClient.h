//
//  StreamURLClient.h
//  radikker
//
//  Created by saiten on 12/10/24.
//
//

#import <Foundation/Foundation.h>

@interface StreamURLClient : NSObject
@property (nonatomic, assign) id delegate;

- (id)initWithDelegate:(id)delegate;
- (void)loadStreamURLWithChannel:(NSString*)channel;

@end

@interface NSObject (StreamURLClientDelegate)
- (void)streamURLClient:(StreamURLClient*)client didReceiveStreamURL:(NSURL*)streamURL;
- (void)streamURLClient:(StreamURLClient*)client didFailWithError:(NSError*)error;
@end