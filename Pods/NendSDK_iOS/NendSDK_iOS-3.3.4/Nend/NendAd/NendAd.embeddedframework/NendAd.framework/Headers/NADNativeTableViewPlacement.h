//
//  NADNativeTableViewPlacement.h
//  NendAd
//
//  Copyright (c) 2015年 F@N Communications, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NADNativeTableViewPlacement : NSObject

- (void)addFixedIndexPath:(NSIndexPath *)indexPath;
- (void)addFixedIndexPath:(NSIndexPath *)indexPath fillRow:(BOOL)fillRow;
- (void)addFixedIndexPath:(NSIndexPath *)indexPath adCount:(NSUInteger)adCount;
- (void)addFixedIndexPath:(NSIndexPath *)indexPath fillRow:(BOOL)fillRow adCount:(NSUInteger)adCount;

- (void)addRepeatInterval:(NSUInteger)interval inSection:(NSUInteger)section;
- (void)addRepeatInterval:(NSUInteger)interval inSection:(NSUInteger)section fillRow:(BOOL)fillRow;
- (void)addRepeatInterval:(NSUInteger)interval inSection:(NSUInteger)section adCount:(NSUInteger)adCount;
- (void)addRepeatInterval:(NSUInteger)interval inSection:(NSUInteger)section fillRow:(BOOL)fillRow adCount:(NSUInteger)adCount;

@end
