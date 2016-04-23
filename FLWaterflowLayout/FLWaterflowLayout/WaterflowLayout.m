//
//  WaterflowLayout.m
//  FLWaterflowLayout
//
//  Created by 冯璐 on 16/4/23.
//  Copyright © 2016年 冯璐. All rights reserved.
//

#import "WaterflowLayout.h"

/** 边缘间距 */  //编译时调用 {} 直接赋值
static const UIEdgeInsets inset = {10, 10, 10, 10};

/** 默认列数 */
static const NSInteger columnCount = 3;

/** 每一行之间的间距 */
static const CGFloat RowMargin = 10;

/** 每一列之间的间距 */
static const CGFloat ColumnMargin = 10;

@interface WaterflowLayout ()

@property (nonatomic, strong) NSMutableArray *attrsArray;

/** 存放所有列的当前高度 */
@property (nonatomic, strong) NSMutableArray *columnHeights;


- (CGFloat)rowMargin;

- (CGFloat)columnMargin;

- (NSInteger)columnCount;

- (UIEdgeInsets)edgeInsets;

@end

@implementation WaterflowLayout


#pragma mark ----- 常用数据处理 ----

- (CGFloat)rowMargin {
    
    if ([self.waterflowLayoutDelegate respondsToSelector:@selector(rowMarginInWaterflowLayout:)]) {
        
        return [self.waterflowLayoutDelegate rowMarginInWaterflowLayout:self];
    }else {
        return RowMargin;
    }
    
}

- (CGFloat)columnMargin {
    
    if ([self.waterflowLayoutDelegate respondsToSelector:@selector(columnMarginInWaterflowLayout:)]) {
        
        return [self.waterflowLayoutDelegate columnMarginInWaterflowLayout:self];
    }else {
        
        return ColumnMargin;
    }
    
}

- (NSInteger)columnCount {
    
    if ([self.waterflowLayoutDelegate respondsToSelector:@selector(columnCountInWaterflowLayout:)]) {
        
        return [self.waterflowLayoutDelegate columnCountInWaterflowLayout:self];
    }else {
        
        return columnCount;
    }
    
}

- (UIEdgeInsets)edgeInsets {
    
    if ([self.waterflowLayoutDelegate respondsToSelector:@selector(edgeInsetsInWaterflowLayout:)]) {
        
        return [self.waterflowLayoutDelegate edgeInsetsInWaterflowLayout:self];
        
    }else {
        
        return inset;
    }
}


//创建一个数组(存放所有cell的布局属性)
- (NSMutableArray *)attrsArray {
    
    if (!_attrsArray) {
        _attrsArray = [[NSMutableArray alloc] init];
    }
    return _attrsArray;
}


- (NSMutableArray *)columnHeights {
    
    if (!_columnHeights) {
        _columnHeights = [[NSMutableArray alloc] init];
    }
    return _columnHeights;
}


/**
 *  初始化
 */
- (void)prepareLayout { //默认刷新时调用一次
    
    //调用父类
    [super prepareLayout];
    
    
    //清除之前计算的的高度
    [self.columnHeights removeAllObjects];
    for (NSInteger i = 0; i < [self columnCount]; i++) {
        [self.columnHeights addObject:@([self edgeInsets].top)];
    }
    
    //清除之前所有的布局属性
    [self.attrsArray removeAllObjects];
    
    //开始创建每一个cell 对应的布局属性
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    
    for (NSInteger i = 0; i < count; i++) {
        
        //创建cell位置
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        
        //获取indexPath位置cell对应的布局属性
        UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:indexPath];
        
        
        //每个属性添加至数组中
        [self.attrsArray addObject:attrs];
        
    }
    
    
    
}

/**
 *  决定cell的排布
 */
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    return self.attrsArray;
}


/**
 *  返回indexPath 位置cell对应的布局属性
 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //创建布局属性
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    //设置布局属性 (frame)
    
    //1> 获取collectionView 宽度
    CGFloat collectionViewW = self.collectionView.frame.size.width;
    
#warning  -- 计算item宽度
    
    CGFloat w = (collectionViewW - ([self edgeInsets].left + [self edgeInsets].right) - [self columnMargin] * ([self columnCount] - 1)) / self.columnCount;
    
#warning  -- 计算item高度
    
    CGFloat h = [self.waterflowLayoutDelegate WaterflowLayout:self heightForItemAtIndex:indexPath.item itemWidth:w];
    
    //找出高度最短的那一列
    
    /* 1> block 遍历
     __block NSInteger destColumn = 0;
     __block CGFloat minColumnHeight = MAXFLOAT;
     
     [self.columnHeights enumerateObjectsUsingBlock:^(NSNumber *columnHeightNumber, NSUInteger idx, BOOL * _Nonnull stop) {
     
     CGFloat columnHeight = columnHeightNumber.doubleValue;
     if (minColumnHeight > columnHeight) {
     minColumnHeight = columnHeight;
     destColumn = idx;
     }
     
     }];
     */
    
    //2> for
    NSInteger destColumn = 0;
    CGFloat minColumnHeight = [self.columnHeights[0] doubleValue];
    
    for (NSInteger i = 1; i < self.columnCount; i++) {
        //取得第i列的高度
        CGFloat columnHeight = [self.columnHeights[i] doubleValue];
        
        if (minColumnHeight > columnHeight) {
            minColumnHeight = columnHeight;
            destColumn = i;
        }
    }
    
    CGFloat x = self.edgeInsets.left + destColumn * (w + self.columnMargin);
    CGFloat y = minColumnHeight;
    
    if (y != self.edgeInsets.top) {
        
        y += self.rowMargin;
    }
    
    attrs.frame = CGRectMake(x, y, w, h);
    
    //更新最短那列的高度
    self.columnHeights[destColumn] = @(CGRectGetMaxY(attrs.frame));
    
    return attrs;
}



/**
 *  collectionView 滑动范围
 */
- (CGSize)collectionViewContentSize {
    
    NSInteger destColumn = 0;
    CGFloat maxColumnHeight = [self.columnHeights[0] doubleValue];
    
    for (NSInteger i = 1; i < self.columnCount; i++) {
        
        if (maxColumnHeight < [self.columnHeights[i] doubleValue]) {
            maxColumnHeight = [self.columnHeights[i] doubleValue];
            destColumn = i;
        }
    }
    
    
    return CGSizeMake(0, maxColumnHeight + self.edgeInsets.bottom);
}

@end
