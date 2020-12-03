//
//  NADInterstitial.h
//  NendAd
//
//  インタースティシャル広告クラス

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

///-----------------------------------------------
/// @name Constants
///-----------------------------------------------

/**
 NADInterstitialClickType
 */
typedef NS_ENUM(NSInteger, NADInterstitialClickType) {
    DOWNLOAD,
    CLOSE,
    INFORMATION
};

/**
 NADInterstitialStatusCode
 */
typedef NS_ENUM(NSInteger, NADInterstitialStatusCode) {
    SUCCESS,
    INVALID_RESPONSE_TYPE,
    FAILED_AD_REQUEST,
    FAILED_AD_DOWNLOAD,
};

/**
 NADInterstitialShowAdResult
 */
typedef NS_ENUM(NSInteger, NADInterstitialShowResult) {
    AD_SHOW_SUCCESS,
    AD_LOAD_INCOMPLETE,
    AD_REQUEST_INCOMPLETE,
    AD_DOWNLOAD_INCOMPLETE,
    AD_FREQUENCY_NOT_REACHABLE,
    AD_SHOW_ALREADY,
    AD_CANNOT_DISPLAY
};

/**
 A delegate object for each event of Interstitial-AD.
 */
@protocol NADInterstitialDelegate <NSObject>

@optional

/**
 Notify the results of the ad load.
 */
- (void)didFinishLoadInterstitialAdWithStatus:(NADInterstitialStatusCode)status;

- (void)didFinishLoadInterstitialAdWithStatus:(NADInterstitialStatusCode)status spotId:(NSString *)spotId;

/**
 Notify the event of the ad click.
 */
- (void)didClickWithType:(NADInterstitialClickType)type;

- (void)didClickWithType:(NADInterstitialClickType)type spotId:(NSString *)spotId;

@end

/**
 The management class of Interstitial-AD.
 */
@interface NADInterstitial : NSObject

/**
 Set the delegate object.
 */
@property (nonatomic, weak, readwrite) id<NADInterstitialDelegate> delegate;

/**
 Log setting.
 */
@property (nonatomic) BOOL isOutputLog;

/**
 Reload the interstitial ad when close.
 Defaults to YES
 */
@property (nonatomic) BOOL enableAutoReload;

/**
 Deprecated. Not used.
 Supported Orientations.
 */
@property (nonatomic) NSArray *supportedOrientations __deprecated_msg("Not used.");

///-----------------------------------------------
/// @name Creating and Initializing Nend Instance
///-----------------------------------------------

/**
 Creates and returns a `NADInterstitial` object.

 @return NADInterstitial
 */
+ (instancetype)sharedInstance;

///------------------------
/// @name Loading AD
///------------------------

/**
 Load the Interstitial-AD.

 @warning　Please call this when the application starts.

 for example:

 `- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions`
 */
- (void)loadAdWithApiKey:(NSString *)apiKey spotId:(NSString *)spotId;

///----------------------------
/// @name Showing / Closing AD
///----------------------------

/**
 Show the Interstitial-AD on the specified UIViewController.
 
 @return NADInterstitialShowResult
 */
- (NADInterstitialShowResult)showAd __deprecated_msg("This method has been replaced by showAdFromViewController:");

- (NADInterstitialShowResult)showAdWithSpotId:(NSString *)spotId __deprecated_msg("This method has been replaced by showAdFromViewController:spotId:");

- (NADInterstitialShowResult)showAdFromViewController:(UIViewController *)viewController;

- (NADInterstitialShowResult)showAdFromViewController:(UIViewController *)viewController spotId:(NSString *)spotId;

/**
 Dismiss the Interstitial-AD.

 @return `YES` AD will be closed, otherwise `NO`.
 */
- (BOOL)dismissAd;

@end
