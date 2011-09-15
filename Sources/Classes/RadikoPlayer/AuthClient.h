//
//  AuthClient.h
//  radikker
//
//  Created by saiten on 11/05/26.
//  Copyright 2011 iside. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "rfxswf.h"
#import "HttpClient.h"

typedef enum {
  AuthClientStateInit,
  AuthClientStateGetPlayer,
  AuthClientStateAuth1,
  AuthClientStateAuth2,
  AuthClientStateSuccess,
  AuthClientStateFailed
} AuthClientState;

@interface AuthClient : NSObject {
  NSString *authToken;
  NSString *areaCode;
  
  int offset;
  int length;
  NSString* partialKey;
  NSData *keyData;
  
  id delegate;
  NSDate *lastAuthDate;
  AuthClientState state;
  NSError *error;
}

@property(nonatomic,readonly) NSString *areaCode;
@property(nonatomic,readonly) NSString *authToken;
@property(nonatomic,readonly) NSString *partialKey;
@property(nonatomic,readonly) AuthClientState state;
@property(nonatomic,readonly) NSDate *lastAuthDate;
@property(nonatomic, readonly) NSError *error;

- (id)initWithDelegate:(id)delegate;
- (void)startAuthentication;
- (void)cancel;

@end

@interface NSObject (AuthClientDelegate)
- (void)authClient:(AuthClient*)client didChangeState:(AuthClientState)state;
@end