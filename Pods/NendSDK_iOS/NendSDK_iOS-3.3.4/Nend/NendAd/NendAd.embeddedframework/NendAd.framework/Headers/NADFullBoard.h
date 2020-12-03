//
//  NADFullBoard.h
//  NendAd
//
//  Copyright © 2016年 F@N Communications, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NADFullBoardView.h"

@class NADFullBoard;

@protocol NADFullBoardDelegate <NADFullBoardViewDelegate>

@optional

- (void)NADFullBoardDidShowAd:(NADFullBoard *)ad;
- (void)NADFullBoardDidDismissAd:(NADFullBoard *)ad;

@end

// deprecated
typedef NS_ENUM(NSInteger, NADFullBoardLayoutType) {
    NADFullBoardLayoutTypeLogoTop,
    NADFullBoardLayoutTypeLogoMiddle
} __deprecated_msg("Not used.");

@interface NADFullBoard : NSObject

@property (nonatomic, weak) id<NADFullBoardDelegate> delegate;

- (void)showFromViewController:(UIViewController *)viewController;
- (UIViewController<NADFullBoardView> *)fullBoardAdViewController;

// deprecated
- (void)showInViewController:(UIViewController *)viewController layoutType:(NADFullBoardLayoutType)type __deprecated_msg("This method has been replaced by showFromViewController:");
- (UIViewController<NADFullBoardView> *)fullScreenAdViewControllerWithType:(NADFullBoardLayoutType)type __deprecated_msg("This method has been replaced by fullBoardAdViewController");

@end
