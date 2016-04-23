//
//  WaterflowLayout.h
//  FLWaterflowLayout
//
//  Created by 冯璐 on 16/4/23.
//  Copyright © 2016年 冯璐. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WaterflowLayout;

@protocol WaterflowLayoutDelegate <NSObject>

@required
- (CGFloat)WaterflowLayout:(WaterflowLayout *)waterflowLayout heightForItemAtIndex:(NSInteger)index itemWidth:(CGFloat)itemWidth;

@optional
- (CGFloat)columnCountInWaterflowLayout:(WaterflowLayout *)waterflowLayout;
- (CGFloat)columnMarginInWaterflowLayout:(WaterflowLayout *)waterflowLayout;
- (CGFloat)rowMarginInWaterflowLayout:(WaterflowLayout *)waterflowLayout;
- (UIEdgeInsets)edgeInsetsInWaterflowLayout:(WaterflowLayout *)waterflowLayout;

@end

@interface WaterflowLayout : UICollectionViewLayout

@property (nonatomic, assign) id<WaterflowLayoutDelegate>waterflowLayoutDelegate;

@end
