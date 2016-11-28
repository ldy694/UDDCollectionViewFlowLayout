//
//  UDDCollectionViewFlowLayout.h
//  uliaobao
//
//  Created by 林兴栋 on 16/11/28.
//  Copyright © 2016年 CGC. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
    扩展每个分区的颜色，同时固定间隔
 */

/// 扩展section的背景色
@protocol UDDCollectionViewDelegateFlowLayout <UICollectionViewDelegateFlowLayout>

- (UIColor *)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout colorForSectionAtIndex:(NSInteger)section;
@end


@interface UDDCollectionViewFlowLayout : UICollectionViewFlowLayout

@end
