//
//  NADNative.h
//  NendAd
//
//  Copyright (c) 2015年 F@N Communications, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NADNativeViewRendering.h"

typedef void (^NADNativeImageCompletionBlock)(UIImage *);

typedef NS_ENUM(NSInteger, NADNativeAdvertisingExplicitly) {
    NADNativeAdvertisingExplicitlyPR,
    NADNativeAdvertisingExplicitlySponsored,
    NADNativeAdvertisingExplicitlyAD,
    NADNativeAdvertisingExplicitlyPromotion,
};

@class NADNative;

@protocol NADNativeDelegate <NSObject>

@optional
- (void)nadNativeDidClickAd:(NADNative *)ad;
- (void)nadNativeDidDisplayAd:(NADNative *)ad success:(BOOL)success __attribute__((deprecated));

@end

@interface NADNative : NSObject

// The title of native ad.
@property (nonatomic, readonly, copy) NSString *shortText;
// The content of native ad.
@property (nonatomic, readonly, copy) NSString *longText;
// The promotion url of native ad.
@property (nonatomic, readonly, copy) NSString *promotionUrl;
// The promotion name of native ad.
@property (nonatomic, readonly, copy) NSString *promotionName;
// The action text of native ad, for example `Install`.
@property (nonatomic, readonly, copy) NSString *actionButtonText;
// The url of image.
@property (nonatomic, readonly, copy) NSString *imageUrl;
// The url of logo.
@property (nonatomic, readonly, copy) NSString *logoUrl;
// The delegate.
@property (nonatomic, weak) id<NADNativeDelegate> delegate;

/**
 * Render ad fields into view.
 */
- (void)intoView:(UIView<NADNativeViewRendering> *)view advertisingExplicitly:(NADNativeAdvertisingExplicitly)advertisingExplicitly;

/**
 * Gets PR text for specified `NADNativeAdvertisingExplicitly`.
 */
- (NSString *)prTextForAdvertisingExplicitly:(NADNativeAdvertisingExplicitly)advertisingExplicitly;

/**
 * To enable ad click.
 */
- (void)activateAdView:(UIView *)view withPrLabel:(UILabel *)prLabel;

/**
 * Download ad image if contains ad image.
 */
- (void)loadAdImageWithCompletionBlock:(NADNativeImageCompletionBlock)block;

/**
 * Download logo image if contains logo image.
 */
- (void)loadLogoImageWithCompletionBlock:(NADNativeImageCompletionBlock)block;

@end

@interface NADNative (Deprecated)

- (void)intoView:(UIView<NADNativeViewRendering> *)view __attribute__((deprecated("Use `intoView:advertisingExplicitly` instead.")));

@end
