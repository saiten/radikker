//
//  ImobileSdkAdsAdParams.h
//
//  Copyright (c) 2015年 i-mobile. All rights reserved.
//

@interface ImobileSdkAdsNativeParams : NSObject

// 画像の読み込みを行うかのフラグ デフォルト値はNOです（YES : 読み込みます NO:読み込みません）
@property (nonatomic) BOOL nativeImageGetFlag;

// 広告の取得数 デフォルト値は1（YES : 読み込みます NO:読み込みません）
@property (nonatomic) NSInteger requestAdCount;

@end
