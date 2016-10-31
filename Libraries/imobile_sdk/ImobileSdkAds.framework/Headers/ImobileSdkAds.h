//
//  ImobileSdkAds.h
//
//  Copyright (c) 2013年 i-mobile. All rights reserved.
//

#pragma mark - ImobileSdkAds
#import "ImobileSdkAdsAdParams.h"
#import "ImobileSdkAdsNativeObject.h"
#import "ImobileSdkAdsTableController.h"


@protocol IMobileSdkAdsDelegate;

#pragma mark 広告の表示レイアウト
typedef enum {
    IMOBILESDKADS_AD_ORIENTATION_AUTO,      // 自動判別
    IMOBILESDKADS_AD_ORIENTATION_PORTRAIT,  // ポートレート固定
    IMOBILESDKADS_AD_ORIENTATION_LANDSCAPE, // ランドスケープ固定
} ImobileSdkAdsAdOrientation;

#pragma mark - 広告表示準備完了時の広告の種類(アプリ側への通知内容)
typedef enum {
    IMOBILESDKADS_READY_AD,                 // 通常広告
    IMOBILESDKADS_READY_HOUSE_AD            // 自社広告
} ImobileSdkAdsReadyResult;

#pragma mark - アプリ側からの確認(getStatusBySpotID)用
typedef enum {
    IMOBILESDKADS_STATUS_READY,
    IMOBILESDKADS_STATUS_NOT_READY,
    IMOBILESDKADS_STATUS_NOT_FOUND,
    IMOBILESDKADS_STATUS_RETRY_WAIT,
    IMOBILESDKADS_STATUS_OTHERS
} ImobileSdkAdsStatus;

#pragma mark - 広告取得失敗時のエラーの種類(アプリ側への通知内容)
typedef enum {
    IMOBILESDKADS_ERROR_PARAM,              // パラメータエラー
    IMOBILESDKADS_ERROR_AUTHORITY,          // 権限エラー
    IMOBILESDKADS_ERROR_RESPONSE,           // レスポンスエラー
    IMOBILESDKADS_ERROR_NETWORK_NOT_READY,  // ネットワーク使用不可
    IMOBILESDKADS_ERROR_NETWORK,            // ネットワークエラー
    IMOBILESDKADS_ERROR_UNKNOWN,            // 不明なエラー
    IMOBILESDKADS_ERROR_AD_NOT_READY,       // 広告表示準備未完了
    IMOBILESDKADS_ERROR_NOT_FOUND,          // 広告切れ
    IMOBILESDKADS_ERROR_SHOW_TIMEOUT        // 広告表示処理タイムアウト
} ImobileSdkAdsFailResult;

#pragma mark -ImobileSdkAds(SDK本体)
/**
 ImobileSdkAds(SDK本体)
 */
@interface ImobileSdkAds : NSObject

/**
 広告を受け取る広告枠の情報を登録します
 @param publisherId パブリッシャーID
 @param mediaId メディアID
 @param spotId スポットID
 @return BOOL 広告枠が登録された場合はYES
 */
+ (BOOL)registerWithPublisherID:(NSString *)publisherId MediaID:(NSString *)mediaId SpotID:(NSString *)spotId;

/**
 登録済みのすべての広告枠の広告取得を開始します
 */
+ (void)start;

/**
 登録済みのすべての広告枠の広告取得を停止します
 */
+ (void)stop;

/**
 登録済みの指定された広告枠の広告取得を開始します
 @param spotId スポットID
 @return BOOL 広告枠が登録された場合はYES
 */
+ (BOOL)startBySpotID:(NSString *)spotId;

/**
 登録済みの指定された広告枠の広告取得を停止します
 @param spotId スポットID
 @return BOOL 広告枠が登録された場合はYES
 */
+ (BOOL)stopBySpotID:(NSString *)spotId;

#pragma mark - 広告の表示
#pragma mark - 広告の表示(全画面)
/**
 登録済みの指定された広告枠が表示可能な場合、広告を表示します
 @param spotId スポットID
 @return BOOL 広告枠が登録された場合はYES
 */
+ (BOOL)showBySpotID:(NSString *)spotId;

#pragma mark - 広告の表示(インライン)
#pragma mark 広告の表示(座標(ViewController)指定)
/**
 登録済みの指定された広告枠が表示可能な場合、広告を表示します(ViewController指定版、表示位置指定版 for インライン)
 @param spotId スポットID
 @param viewController 表示を行う対象となるUIViewController
 @param position 表示を行う座標
 @return BOOL スポットが登録済みの場合はYES
 */
+ (BOOL)showBySpotID:(NSString *)spotId ViewController:(UIViewController *)viewController Position:(CGPoint)position;

/**
 登録済みの指定された広告枠が表示可能な場合、広告を表示します(ViewController指定版、表示位置指定版 for インライン 広告表示を横幅に合わせるフラグ指定可(アイコン広告の場合は無効))
 @param spotId スポットID
 @param viewController 表示を行う対象となるUIViewController
 @param position 表示を行う座標
 @param sizeAdjust デバイスの横幅に合わせて自動調整を行う場合はYES
 @return BOOL スポットが登録済みの場合はYES
 */
+ (BOOL)showBySpotID:(NSString *)spotId ViewController:(UIViewController *)viewController Position:(CGPoint)position SizeAdjust:(BOOL)sizeAdjust;

#pragma mark 広告の表示(View指定)
/**
 登録済みの指定された広告枠が表示可能な場合、広告を表示します(View指定版 for インライン)
 @param spotId スポットID
 @param view 表示を行う対象となるUIView
 @return BOOL スポットが登録済みの場合はYES
 */
+ (BOOL)showBySpotID:(NSString *)spotId View:(UIView *)view;

/**
 登録済みの指定された広告枠が表示可能な場合、広告を表示します(View指定版 for インライン 広告表示を横幅に合わせるフラグ指定可(アイコン広告の場合は無効))
 @param spotId スポットID
 @param view 表示を行う対象となるUIView
 @param sizeAdjust デバイスの横幅に合わせて自動調整を行う場合はYES
 @return BOOL スポットが登録済みの場合はYES
 */
+ (BOOL)showBySpotID:(NSString *)spotId View:(UIView *)view SizeAdjust:(BOOL)sizeAdjust;

#pragma mark - 広告の取得（ネイティブ)
/**
 ネイティブ広告の読み込みを開始します。
 @param spotId スポットID
 @return BOOL スポットが登録済みの場合はYES
 */
+ (BOOL)getNativeAdData:(NSString *)spotId Delegate:(id<IMobileSdkAdsDelegate>)deleage;

/**
 ネイティブ広告の読み込みを開始します。
 @param spotId スポットID
 @return BOOL スポットが登録済みの場合はYES
 */
+ (BOOL)getNativeAdData:(NSString *)spotId ViewController:(UIViewController *)viewController Delegate:(id<IMobileSdkAdsDelegate>)deleage;

/**
 パラメータを付加してネイティブ広告の読み込みを開始します。
 @param spotId スポットID
 @pramm params ネイティブ広告のパラメーター
 @return BOOL 広告枠が登録済みの場合はYES
 */
+ (BOOL)getNativeAdData:(NSString *)spotId Params:(ImobileSdkAdsNativeParams *)params Delegate:(id<IMobileSdkAdsDelegate>)deleage;

/**
 パラメータを付加してネイティブ広告の読み込みを開始します。
 @param spotId スポットID
 @pramm params ネイティブ広告のパラメーター
 @return BOOL 広告枠が登録済みの場合はYES
 */
+ (BOOL)getNativeAdData:(NSString *)spotId ViewController:(UIViewController *)viewController Params:(ImobileSdkAdsNativeParams *)params Delegate:(id<IMobileSdkAdsDelegate>)deleage;

+ (BOOL)getNativeAdData:(NSString *)spotId View:(UIView *)view Params:(ImobileSdkAdsNativeParams *)params Delegate:(id<IMobileSdkAdsDelegate>)deleage;

#pragma mark ネイティブ広告時のtableViewに広告の表示を行う
/**
 tableViewに対して広告を表示します。
 @param spotId スポットID
 @param tableView 表示対象のテーブルビュー
 @param nibFileName nibファイルの名前を指定します
 */
+ (ImobileSdkAdsTableController *)getTableController:(NSString *)spotId TableView:(UITableView *)tableView Nib:(UINib *)Nib;

/**
 tableViewに対して広告を表示します。
 @param spotId スポットID
 @param tableView 表示対象のテーブルビュー
 @param nibFileName nibファイルの名前を指定します
 @param params ネイティブ広告用のパラメータを指定します。
 */
+ (ImobileSdkAdsTableController *)getTableController:(NSString *)spotId TableView:(UITableView *)tableView Nib:(UINib *)Nib Params:(ImobileSdkAdsNativeParams *)params;

#pragma mark 広告の表示(インライン AdMobMediation)
/**
 AdMobMediation用のShowAd
 @param spotId スポットID
 @param view 表示を行う対象となるUIView
 @return BOOL スポットが登録済みの場合はYES
 */
+ (BOOL)showBySpotIDForAdMobMediation:(NSString *)spotId View:(UIView *)view;

#pragma mark - setter

/**
 SDKのメッセージを受け取るデリゲートを設定します
 @param spotId スポットID
 @param delegate デリゲートメソッド
 @return BOOL スポットが登録済みの場合はYES
 */
+ (BOOL)setSpotDelegate:(NSString *)spotId delegate:(id<IMobileSdkAdsDelegate>)delegate;

/**
 テストモードの設定をします
 @param isTestMode テスト広告を配信する場合はYES
 */
+ (void)setTestMode:(BOOL)isTestMode;

/**
 広告が表示される向きの設定
 @param orientation 広告が表示される向き
 */
+ (void)setAdOrientation:(ImobileSdkAdsAdOrientation)orientation;

/**
 ルートコントロールビューを設定します
 @param rootViewController ルートビューコントローラ
 */
+ (void)setRootViewController:(UIViewController *)rootViewController;

/**
 Xcode5(iOS7 SDK)でのビルドに対応するかを設定
 @param isLegacyMode レガシモードを行う場合はYES
 */
+ (void)setLegacyIosSdkMode:(BOOL)isLegacyMode;

/**
 オフスクリーンウインドウのウインドウレベルを設定します
 @param windowLevel UIWindowLevelで設定を行います。
 */
+ (void)setOffscreenWindowLevel:(UIWindowLevel)windowLevel __deprecated;

#pragma mark - getter
/**
 登録済みの指定された広告枠の状態を取得します<br />
 スポットが登録されていない場合は、nilが返ります。
 @param spotId スポットID
 @return ImobileSdkAdsStatus
 */
+ (ImobileSdkAdsStatus)getStatusBySpotID:(NSString *)spotId;

/**
 skipCountに達するまで、Showメソッドが呼ばれた回数の取得
 @param spotId UIWindowLevelで設定を行います。
 @return NSNumber skipCountに到達するまでのShowが呼ばれた回数を取得します。<br />スポットが登録されていない場合はnil
 */
+ (NSNumber *)getCountAttemptsToShowBySpotID:(NSString *)spotId;

/**
 Showメソッドが呼ばれた回数の合計の取得
 @param spotId スポットID
 @return NSNumber Showが呼ばれた回数を取得します。<br />スポットが登録されていない場合はnil
 */
+ (NSNumber *)getCountAttemptsToShowTotalBySpotID:(NSString *)spotId;

@end


#pragma mark - IMobileSdkAdsDelegate
/**
 SDKのメッセージを受け取るデリゲート(アプリ単位)
 */
@protocol IMobileSdkAdsDelegate <NSObject>

/**
 広告の表示が準備完了した際に呼ばれます
 @param spotId スポットID
 @param value ImobileSdkAdsReadyResultでの広告の種類を取得することができます。
 */
@optional
- (void)imobileSdkAdsSpot:(NSString *)spotId didReadyWithValue:(ImobileSdkAdsReadyResult)value;

/**
 広告の取得を失敗した際に呼ばれます
 @param spotId スポットID
 @param value ImobileSdkAdsFailResultでの失敗理由を取得することができます。
 */
@optional
- (void)imobileSdkAdsSpot:(NSString *)spotId didFailWithValue:(ImobileSdkAdsFailResult)value;

/**
 広告の表示要求があった際に、準備が完了していない場合に呼ばれます
 @param spotId スポットID
 */
@optional
- (void)imobileSdkAdsSpotIsNotReady:(NSString *)spotId;

/**
 広告をクリックした際に呼ばれます
 @param spotId スポットID
 */
@optional
- (void)imobileSdkAdsSpotDidClick:(NSString *)spotId;

/**
 広告を閉じた際に呼ばれます(広告の表示がスキップされた場合も呼ばれます)
 @param spotId スポットID
 */
@optional
- (void)imobileSdkAdsSpotDidClose:(NSString *)spotId;

/**
 広告の表示が完了した際に呼ばれます
 @param spotId スポットID
 */
@optional
- (void)imobileSdkAdsSpotDidShow:(NSString *)spotId;

/**
 ネイティブ広告の読み込みが完了した際に呼ばれます
 @param spotId スポットID
 @param nativeArray 広告リスト
 */
@optional
- (void)onNativeAdDataReciveCompleted:(NSString *)spotId nativeArray:(NSArray *)nativeArray;

@end