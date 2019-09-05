//
//  NADNativeTableViewHelper.h
//  NendAd
//
//  Copyright (c) 2015年 F@N Communications, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NADNativeClient.h"
#import "NADNativeTableViewPlacement.h"

@protocol NADNativeTableViewHelperDelegate <NADNativeDelegate>

- (UITableViewCell *)tableView:(UITableView *)tableView adCellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView heightForAdRowAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForAdRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface NADNativeTableViewHelper : NSObject

+ (instancetype)helperWithTableView:(UITableView *)tableView
                             spotId:(NSString *)spotId
                             apiKey:(NSString *)apiKey
              advertisingExplicitly:(NADNativeAdvertisingExplicitly)advertisingExplicitly
                        adPlacement:(NADNativeTableViewPlacement *)adPlacement
                           delegate:(id<NADNativeTableViewHelperDelegate>)delegate;

+ (instancetype)helperWithTableView:(UITableView *)tableView
                             spotId:(NSString *)spotId
                             apiKey:(NSString *)apiKey
              advertisingExplicitly:(NADNativeAdvertisingExplicitly)advertisingExplicitly
                        adPlacement:(NADNativeTableViewPlacement *)adPlacement
                           delegate:(id<NADNativeTableViewHelperDelegate>)delegate
               placeholderCellClass:(Class)placeholderCellClass;

+ (instancetype)helperWithTableView:(UITableView *)tableView
                             spotId:(NSString *)spotId
                             apiKey:(NSString *)apiKey
              advertisingExplicitly:(NADNativeAdvertisingExplicitly)advertisingExplicitly
                        adPlacement:(NADNativeTableViewPlacement *)adPlacement
                           delegate:(id<NADNativeTableViewHelperDelegate>)delegate
             placeholderCellNibName:(NSString *)placeholderCellNibName;

@end

@interface NADNativeTableViewHelper (IndexPathManipulations)

- (NSIndexPath *)originalIndexPathForActualIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)actualIndexPathForOriginalIndexPath:(NSIndexPath *)indexPath;

@end