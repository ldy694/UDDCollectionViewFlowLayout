//
//  UDDCollectionViewFlowLayout.m
//  uliaobao
//
//  Created by 林兴栋 on 16/11/28.
//  Copyright © 2016年 CGC. All rights reserved.
//

#import "UDDCollectionViewFlowLayout.h"


static NSString *const UDDCollectionViewSectionColor = @"com.UDD.UDDCollectionElementKindSectionColor";


@interface UDDCollectionViewLayoutAttributes  : UICollectionViewLayoutAttributes
// 背景色
@property (nonatomic, strong) UIColor *backgroudColor;
- (void)leftAlignFrameWithSectionInset:(UIEdgeInsets)sectionInset;

@end

@implementation UDDCollectionViewLayoutAttributes
- (void)leftAlignFrameWithSectionInset:(UIEdgeInsets)sectionInset
{
    CGRect frame = self.frame;
    frame.origin.x = sectionInset.left;
    self.frame = frame;
}
@end

@interface UDDCollectionReusableView : UICollectionReusableView

@end


@implementation UDDCollectionReusableView

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes{
    [super applyLayoutAttributes:layoutAttributes];
    UDDCollectionViewLayoutAttributes *attr = (UDDCollectionViewLayoutAttributes *)layoutAttributes;
    self.backgroundColor = attr.backgroudColor;
}

@end



@interface UDDCollectionViewFlowLayout  ()

@property (nonatomic, strong) UIColor *sectonColor;
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *decorationViewAttrs;

@end


@implementation UDDCollectionViewFlowLayout

- (void)prepareLayout{
    [super prepareLayout];
    
    NSInteger sections = [self.collectionView numberOfSections];
    id<UDDCollectionViewDelegateFlowLayout> delegate  = self.collectionView.delegate;
    if ([delegate respondsToSelector:@selector(collectionView:layout:colorForSectionAtIndex:)]) {
    }else{
        return ;
    }
    
    //1.初始化
    [self registerClass:[UDDCollectionReusableView class] forDecorationViewOfKind:UDDCollectionViewSectionColor];
    [self.decorationViewAttrs removeAllObjects];
    
    for (NSInteger section =0; section < sections; section++) {
        NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
        if (numberOfItems > 0) {
            UICollectionViewLayoutAttributes *firstAttr = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
            UICollectionViewLayoutAttributes *lastAttr = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:(numberOfItems - 1) inSection:section]];
            
            UIEdgeInsets sectionInset = self.sectionInset;
            if ([delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
                UIEdgeInsets inset = [delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
                if (!UIEdgeInsetsEqualToEdgeInsets(inset, sectionInset)) {
                    sectionInset = inset;
                }
            }
            
            
            CGRect sectionFrame = CGRectUnion(firstAttr.frame, lastAttr.frame);
            sectionFrame.origin.x -= sectionInset.left;
            sectionFrame.origin.y -= sectionInset.top;
            if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
                sectionFrame.size.width += sectionInset.left + sectionInset.right;
                sectionFrame.size.height = self.collectionView.frame.size.height;
            }else{
                sectionFrame.size.width = self.collectionView.frame.size.width;
                sectionFrame.size.height += sectionInset.top + sectionInset.bottom;
            }
            
            //2. 定义
            UDDCollectionViewLayoutAttributes *attr = [UDDCollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:UDDCollectionViewSectionColor withIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
            attr.frame = sectionFrame;
            attr.zIndex = -1;
            attr.backgroudColor = [delegate collectionView:self.collectionView layout:self colorForSectionAtIndex:section];
            [self.decorationViewAttrs addObject:attr];
        }else{
            continue ;
        }
    }
    
}
/**
 
 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UDDCollectionViewLayoutAttributes* currentItemAttributes = [[super layoutAttributesForItemAtIndexPath:indexPath] copy];
    UIEdgeInsets sectionInset = [self evaluatedSectionInsetForItemAtIndex:indexPath.section];
    
    BOOL isFirstItemInSection = indexPath.item == 0;
    CGFloat layoutWidth = CGRectGetWidth(self.collectionView.frame) - sectionInset.left - sectionInset.right;
    
    if (isFirstItemInSection) {
        [currentItemAttributes leftAlignFrameWithSectionInset:sectionInset];
        return currentItemAttributes;
    }
    
    NSIndexPath* previousIndexPath = [NSIndexPath indexPathForItem:indexPath.item-1 inSection:indexPath.section];
    CGRect previousFrame = [self layoutAttributesForItemAtIndexPath:previousIndexPath].frame;
    CGFloat previousFrameRightPoint = previousFrame.origin.x + previousFrame.size.width;
    CGRect currentFrame = currentItemAttributes.frame;
    CGRect strecthedCurrentFrame = CGRectMake(sectionInset.left,
                                              currentFrame.origin.y,
                                              layoutWidth,
                                              currentFrame.size.height);
    // if the current frame, once left aligned to the left and stretched to the full collection view
    // widht intersects the previous frame then they are on the same line
    BOOL isFirstItemInRow = !CGRectIntersectsRect(previousFrame, strecthedCurrentFrame);
    
    if (isFirstItemInRow) {
        // make sure the first item on a line is left aligned
        [currentItemAttributes leftAlignFrameWithSectionInset:sectionInset];
        return currentItemAttributes;
    }
    
    CGRect frame = currentItemAttributes.frame;
    frame.origin.x = previousFrameRightPoint + [self evaluatedMinimumInteritemSpacingForSectionAtIndex:indexPath.section];
    currentItemAttributes.frame = frame;
    return currentItemAttributes;
}

- (CGFloat)evaluatedMinimumInteritemSpacingForSectionAtIndex:(NSInteger)sectionIndex
{
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
        id<UDDCollectionViewDelegateFlowLayout> delegate = (id<UDDCollectionViewDelegateFlowLayout>)self.collectionView.delegate;
        
        return [delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:sectionIndex];
    } else {
        return self.minimumInteritemSpacing;
    }
}

- (UIEdgeInsets)evaluatedSectionInsetForItemAtIndex:(NSInteger)index
{
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        id<UDDCollectionViewDelegateFlowLayout> delegate = (id<UDDCollectionViewDelegateFlowLayout>)self.collectionView.delegate;
        
        return [delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:index];
    } else {
        return self.sectionInset;
    }
}

/**
 
 */
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSArray *originalAttributes = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *updatedAttributes = [NSMutableArray arrayWithArray:originalAttributes];
    for (UICollectionViewLayoutAttributes *attributes in originalAttributes) {
        if (!attributes.representedElementKind) {
            NSUInteger index = [updatedAttributes indexOfObject:attributes];
            updatedAttributes[index] = [self layoutAttributesForItemAtIndexPath:attributes.indexPath];
        }
    }
    for (UICollectionViewLayoutAttributes *attr in self.decorationViewAttrs) {
        if (CGRectIntersectsRect(rect, attr.frame)) {
            [updatedAttributes addObject:attr];
        }
    }
    return updatedAttributes;
//    NSMutableArray * attrs = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
//    for (UICollectionViewLayoutAttributes *attr in self.decorationViewAttrs) {
//        if (CGRectIntersectsRect(rect, attr.frame)) {
//            [attrs addObject:attr];
//        }
//    }
//    return [attrs copy];
    

}

- (NSMutableArray<UICollectionViewLayoutAttributes *> *)decorationViewAttrs{
    if (!_decorationViewAttrs) {
        _decorationViewAttrs = [NSMutableArray array];
    }
    return _decorationViewAttrs;
}

@end
