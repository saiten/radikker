//
//  ImobileSdkAdsNativeObject.h
//
//  Copyright (c) 2015年 i-mobile. All rights reserved.
//


@interface ImobileSdkAdsNativeObject : UIView

/**
 クリックイベントを対象となるUIViewに付加します。
 @param targetView 対象となるUIView
 */
- (void)addClickFunction:(UIView *)targetView;

/**
 画像の読み込みを行います
 @param handler 画像読み込み時に実行されるhandlerです
 */
- (void)getAdImageCompleteHandler:(void (^)(UIImage *loadimg))handler;

/**
 WebViewを破棄します
 */
- (void)destroy;

/**
 Unityで使用中
 */
-(void)sendClick;

/**
 タイトルを返却します。
 @return NSString タイトル
 */
- (NSString *)getAdTitle;

/**
 ディスクリプションを返却します。
 @return NSString ディスクリプション
 */
- (NSString *)getAdDescription;

/**
 スポンサードを返却します。
 @return NSString スポンサード
 */
- (NSString *)getAdSponsored;

/**
 画像を返却します。
 @return UIImage 画像
 */
- (UIImage *)getAdImage;

@end