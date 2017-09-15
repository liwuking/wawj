//
//  ZQCycleScroView.m
//  ZQCycleScrollView
//
//  Created by quange on 15/6/16.
//  Copyright (c) 2015年 KingHan. All rights reserved.
//

#import "ZQCycleScroView.h"
#import "ZQCycleCell.h"

static NSString *cycleIdentifier = @"cycleCell";

@interface ZQCycleScroView ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic,strong) UICollectionView *mainView; // 显示图片的collectionView
@property (nonatomic,strong) NSTimer *timer; // 循环滚动的定时器
@property (nonatomic,assign) NSInteger totalItemsCount; // cell的个数
@property (nonatomic,strong) UIPageControl *pageControl;
@property (nonatomic,strong) NSArray *imagesGroup; // 图片数组

@end

@implementation ZQCycleScroView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
    
        // 循环滚动时间默认为1s
//        self.autoScrollTimeInterval = 2.0;
        
        // 创建collectionView
        [self createMainView];

    }
    
    return self;
}

/**
 *  创建循环滚动视图
 */
- (void)createMainView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = self.frame.size;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.mainView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:flowLayout];
    self.mainView.pagingEnabled = YES;
    self.mainView.showsHorizontalScrollIndicator = NO;
    self.mainView.showsVerticalScrollIndicator = NO;
    self.mainView.dataSource = self;
    self.mainView.delegate = self;
    [self addSubview:self.mainView];
    
    // 注册一个cell
    [self.mainView registerNib:[UINib nibWithNibName:@"ZQCycleCell" bundle:nil] forCellWithReuseIdentifier:cycleIdentifier];
}

/**
 *  创建一个pageControl
 */
- (void)createPageControl
{
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.numberOfPages = self.imagesGroup.count;
    self.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    //self.pageControl.currentPageIndicatorTintColor = RGB_COLOR(17, 132, 212);
    [self addSubview:self.pageControl];
}

/**
 *  创建循环滚动视图
 *
 *  @param frame       循环滚动视图的尺寸
 *  @param imagesGroup 图片数组
 *
 *  @return 当期对象
 */
+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame imagesGroup:(NSArray *)imagesGroup
{
    ZQCycleScroView *cycleScrollView = [[self alloc] initWithFrame:frame];
    cycleScrollView.imagesGroup = imagesGroup;
    
    return cycleScrollView;
}

/**
 *  重写图片的set方法
 *
 */
- (void)setImagesGroup:(NSArray *)imagesGroup
{
    if (_imagesGroup != imagesGroup) {
        
        _imagesGroup = imagesGroup;
        _totalItemsCount = _imagesGroup.count * 100;
        // 创建一个定时器
        [self createTimer];
        // 根据图片的个数创建一个pageControl
        [self createPageControl];
    }
}

/**
 *  重新设置定时器的时间
 *
 *  @param autoScrollTimeInterval 定时器的时间
 */
- (void)setAutoScrollTimeInterval:(CGFloat)autoScrollTimeInterval
{
    if (_autoScrollTimeInterval != autoScrollTimeInterval) {
        
        _autoScrollTimeInterval = autoScrollTimeInterval;
        
        // 关掉原来的定时器
        [self.timer invalidate];
        self.timer = nil;
        // 重新开始一个新的定时器
        [self createTimer];
    }
}

/**
 *  创建一个定时器
 */
- (void)createTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollTimeInterval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

/**
 *  自动滚动
 */
- (void)automaticScroll
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.mainView.collectionViewLayout;
    
    NSInteger cutrrentIndex = self.mainView.contentOffset.x / flowLayout.itemSize.width;
    NSInteger targetIndex = cutrrentIndex + 1;
    
    // 如果自动滑到最后一张
    if (targetIndex == self.totalItemsCount) {
        
        targetIndex = self.totalItemsCount * 0.5;
        [self.mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    
    // 顺序滑动播放
    [self.mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 设置collectonView的frame
    self.mainView.frame = self.bounds;
    
    // 一开始就让collView在中间开始
    if (self.mainView.contentOffset.x == 0) {
        
        [self.mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.totalItemsCount * 0.5 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    
    // 布局pageControl
    CGPoint center = self.center;
    center.y = self.frame.size.height - self.pageControl.frame.size.height - 10;
    self.pageControl.center = center;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _totalItemsCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZQCycleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cycleIdentifier forIndexPath:indexPath];
    NSInteger itemIndex = indexPath.item % self.imagesGroup.count;
    
    UIImageView *image = self.imagesGroup[itemIndex];
    cell.imageView.image = image.image;

    return cell;
}

#pragma mark - UICollectionViewDelgate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(cycleScrollView:didSelectItemAtIndex:)]) {
        
        NSInteger itemIndex = indexPath.item % self.imagesGroup.count;
        [self.delegate cycleScrollView:self didSelectItemAtIndex:itemIndex];
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger itemIndex = (scrollView.contentOffset.x + self.mainView.frame.size.width * 0.5) /self.mainView.frame.size.width;
    NSInteger indexOnPageControl = itemIndex % self.imagesGroup.count;
    self.pageControl.currentPage = indexOnPageControl;
}

/**
 *  将要开始拖拽
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.timer invalidate];
    self.timer = nil;
}

/**
 *  拖拽结束
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self createTimer];
}


@end
