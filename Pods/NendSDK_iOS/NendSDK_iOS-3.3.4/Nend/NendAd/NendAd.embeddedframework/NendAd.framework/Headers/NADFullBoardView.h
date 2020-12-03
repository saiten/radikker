//
//  NADFullBoardView.h
//  NendAd
//
//  Copyright © 2016年 F@N Communications, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NADFullBoard;

@protocol NADFullBoardViewDelegate <NSObject>

@optional
- (void)NADFullBoardDidClickAd:(NADFullBoard *)ad;

@end

@protocol NADFullBoardView <NSObject>

@property (nonatomic, weak) id<NADFullBoardViewDelegate> delegate;

- (void)enableCloseButtonWithClickHandler:(dispatch_block_t)handler;

@end
