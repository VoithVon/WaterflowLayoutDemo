//
//  ViewController.m
//  FLWaterflowLayout
//
//  Created by 冯璐 on 16/4/23.
//  Copyright © 2016年 冯璐. All rights reserved.
//

#import "ViewController.h"
#import "WaterflowLayout.h"
#import "MJRefresh.h"

@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,WaterflowLayoutDelegate>

@property (nonatomic, strong) UICollectionView *FLCollectionView;

@end

NSString * const cellID = @"star";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"瀑布流布局";
    
    //创建 collectionView
    
    // 1> 创建流水布局
    WaterflowLayout *layout = [[WaterflowLayout alloc] init];
    
    // 2> 初始化collectionView
    self.FLCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    
    // 3> 设置代理
    self.FLCollectionView.delegate = self;
    self.FLCollectionView.dataSource = self;
    
    // 4> 添加至view
    [self.view addSubview:self.FLCollectionView];
    
//     5> 注册cell
//        [self.FLCollectionView registerNib:[UINib nibWithNibName:@"FLCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:cellID];
    
    [self.FLCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID];
    
    
    //设置瀑布流布局
    layout.waterflowLayoutDelegate = self;
    
    
    //    [self setUpRefresh];
    
}

- (void)setUpRefresh {
    
    //下拉刷新
    self.FLCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        //1> 先删除之前的数组中数据, 后加入新数据至数组中
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            //2> 最后回到主线程刷新
            [self.FLCollectionView reloadData];
            
            [self.FLCollectionView.mj_header endRefreshing];
            
        });
        
    }];
    
    [self.FLCollectionView.mj_header beginRefreshing];
    
    
    //上拉加载
    self.FLCollectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        //从原数组中再增加部分数据至数组中
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            //刷新视图
            [self.FLCollectionView.mj_footer endRefreshing];
            
        });
        
    }];
    
    //视图刷新前隐藏footer
    self.FLCollectionView.mj_footer.hidden = YES;
    
}


#pragma mark ------ UIScrollViewDelegate 代理方法

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//
//    CGFloat offsetY = scrollView.contentOffset.y + self.FLCollectionView.contentInset.top;
//
//    CGFloat panTranslationY = [scrollView.panGestureRecognizer translationInView:self.FLCollectionView].y;
//
//    if (offsetY > 64) {
//
//        if (panTranslationY > 0) { //下滑趋势
//
//            [self.navigationController setNavigationBarHidden:NO animated:YES];
//
//        } else { //上滑趋势
//
//            [self.navigationController setNavigationBarHidden:YES animated:YES];
//        }
//
//    } else {
//
//        [self.navigationController setNavigationBarHidden:NO animated:YES];
//    }
//
//
//}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    NSLog(@"======= %lf", velocity.y);
    
    if (velocity.y > 0) {
        
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
    } else {
        
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
}


#pragma mark -------- waterflowLayoutDelegate 代理方法

- (CGFloat)WaterflowLayout:(WaterflowLayout *)waterflowLayout heightForItemAtIndex:(NSInteger)index itemWidth:(CGFloat)itemWidth {
    
    return itemWidth * 120 / (60 + arc4random_uniform(20));
    
}


- (CGFloat)columnCountInWaterflowLayout:(WaterflowLayout *)waterflowLayout {
    
    return 3;
}

- (CGFloat)columnMarginInWaterflowLayout:(WaterflowLayout *)waterflowLayout {
    
    return 20;
}

- (CGFloat)rowMarginInWaterflowLayout:(WaterflowLayout *)waterflowLayout {
    
    return 20;
}

- (UIEdgeInsets)edgeInsetsInWaterflowLayout:(WaterflowLayout *)waterflowLayout {
    
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark -------- collectionView dataSource 代理方法


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    self.FLCollectionView.mj_footer.hidden = 0 == 1;
    return 50;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}



@end
