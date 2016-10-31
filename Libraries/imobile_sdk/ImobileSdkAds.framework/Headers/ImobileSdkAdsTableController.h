//
//  ImobileSdkAdsTableController.h
//  ImobileSdkAds
//
//  Created by i-mobile on 2015/12/17.
//  Copyright © 2015年 i-mobile. All rights reserved.
//

/**
 インフィードタイプで広告を表示する際に使用するinterfaceです
 */
@interface ImobileSdkAdsTableController : NSObject

/**
 広告のセルを除いた指定のセルのrowを取得します
 @params indexPath 取得を行いたいセル番号
 @return NSInteget 広告のセルを除いた時のrowを返します
 */
- (NSInteger)getOriginalCellPostion:(NSIndexPath *)indexPath;
- (BOOL)isAdCellWithCellIndex:(NSIndexPath *)indexPath;

@end
