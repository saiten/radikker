//
//  NADNativeViewRendering.h
//  NendAd
//
//  Copyright (c) 2015年 F@N Communications, Inc. All rights reserved.
//

#import "NADNativeImageView.h"
#import "NADNativeLabel.h"

@protocol NADNativeViewRendering <NSObject>

@required

/**
 * Return the UILabel for the PR text.
 *
 * @return a UILabel that is used for the PR text.
 */
- (UILabel *)prTextLabel;

@optional

/**
 * Return the UIImageView for the AD image.
 *
 * @return a UIImageView that is used for the AD image.
 */
- (UIImageView *)adImageView;

/**
 * Return the UIImageView for the logo image.
 *
 * @return a UIImageView that is used for the logo image.
 */
- (UIImageView *)nadLogoImageView;

/**
 * Return the UILabel for the short text.
 *
 * @return a UILabel that is used for the short text.
 */
- (UILabel *)shortTextLabel;

/**
 * Return the UILabel for the long text.
 *
 * @return a UILabel that is used for the long text.
 */
- (UILabel *)longTextLabel;

/**
 * Return the UILabel for the promotion url.
 *
 * @return a UILabel that is used for the promotion url.
 */
- (UILabel *)promotionUrlLabel;

/**
 * Return the UILabel for the promotion name.
 *
 * @return a UILabel that is used for the promotion name.
 */
- (UILabel *)promotionNameLabel;

/**
 * Return the UILabel for the action button text.
 *
 * @return a UILabel that is used for the action button text.
 */
- (UILabel *)actionButtonTextLabel;

@end
