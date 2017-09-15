

#import "EWPhotoViewer.h"
#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#define S_WIDTH [UIScreen mainScreen].bounds.size.width
#define S_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface EWPhotoViewer ()<UIScrollViewDelegate>
{
    BOOL _doubleTap;
}
@property (nonatomic, copy)SelectBlock blk;
@property (nonatomic, assign)BOOL isShow;
@end

@implementation EWPhotoViewer

+ (instancetype)instance
{
    static EWPhotoViewer *photo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        photo = [[EWPhotoViewer alloc] init];
    });
    return photo;
}

/**
 * 功能：显示大图
 * 参数：image    小图
 * 参数：imageURL 小图地址
 * 参数：isShow   是否显示选中按钮
 */
- (void)showImage:(UIImage *)image imageURL:(NSString *)imageURL isShow:(BOOL)isShow block:(SelectBlock)block
{
    _blk = block;
    _isShow = isShow;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *backgroundView = [[UIView alloc] initWithFrame:window.bounds];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.tag = 1001001;
    backgroundView.alpha = 0;
    [window addSubview:backgroundView];
    
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:backgroundView.frame];
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor blackColor];
    scrollView.tag = 1001002;
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = 1.5;
    [backgroundView addSubview:scrollView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.tag = 1001003;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    if (imageURL) {
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageURL]
                     placeholderImage:image
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
         {
             
         }];
    }
    
    imageView.userInteractionEnabled = YES;
    [scrollView addSubview:imageView];
    
    //gesture
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapgesture:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delaysTouchesBegan = YES;
    [backgroundView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDobleTapguesture:)];
    doubleTap.numberOfTapsRequired = 2;
    [imageView addGestureRecognizer:doubleTap];
    
    
    //button
    if (isShow) {
        UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        float btn_w = 50;
        float btn_h = 50;
        selectButton.frame = CGRectMake(S_WIDTH-btn_w-10, 20, btn_w, btn_h);
        selectButton.selected = YES;
        selectButton.tag = 1001004;
        [selectButton setImage:[UIImage imageNamed:@"t_delete_no"] forState:UIControlStateNormal];
        [selectButton setImage:[UIImage imageNamed:@"t_delete_yes"] forState:UIControlStateSelected];
        [selectButton addTarget:self action:@selector(selectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundView addSubview:selectButton];
    }
    
    [self adjustImageFrame:image];
    
    [UIView animateWithDuration:0.2 animations:^{
        backgroundView.alpha = 1;
    }];
}

- (void)adjustImageFrame:(UIImage *)image
{
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIScrollView *tempScroll = (UIScrollView *)[window viewWithTag:1001002];
    UIImageView *tempImageView = (UIImageView *)[window viewWithTag:1001003];
    
    // 基本尺寸参数
    CGSize boundsSize = [UIScreen mainScreen].bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    
    CGSize imageSize = image.size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
    
    // 设置伸缩比例
    CGFloat widthRatio = boundsWidth/imageWidth;
    CGFloat heightRatio = boundsHeight/imageHeight;
    CGFloat minScale = (widthRatio > heightRatio) ? heightRatio : widthRatio;
    
    if (minScale >= 1) {
        minScale = 1.0;
    }
    
    CGFloat maxScale =1.5;
    
    
    tempScroll.maximumZoomScale = maxScale;
    tempScroll.minimumZoomScale = minScale;
    tempScroll.zoomScale = minScale;
    
    CGRect imageFrame = CGRectMake(0, 0, boundsWidth, imageHeight * boundsWidth / imageWidth);
    // 内容尺寸
    tempScroll.contentSize = CGSizeMake(0, imageFrame.size.height);
    
    // 宽大
    if ( imageWidth <= imageHeight &&  imageHeight <  boundsHeight ) {
        imageFrame.origin.x = floorf( (boundsWidth - imageFrame.size.width ) / 2.0) * minScale;
        imageFrame.origin.y = floorf( (boundsHeight - imageFrame.size.height ) / 2.0) * minScale;
    }else{
        imageFrame.origin.x = floorf( (boundsWidth - imageFrame.size.width ) / 2.0);
        imageFrame.origin.y = floorf( (boundsHeight - imageFrame.size.height ) / 2.0);
    }
    
    tempImageView.frame = imageFrame;
    
    CGFloat offsetX = (boundsWidth> tempScroll.contentSize.width)?
    (boundsWidth - tempScroll.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (boundsHeight > tempScroll.contentSize.height)?
    (boundsHeight - tempScroll.contentSize.height) * 0.5 : 0.0;
    tempImageView.center = CGPointMake(tempScroll.contentSize.width * 0.5 + offsetX,
                                       tempScroll.contentSize.height * 0.5 + offsetY);
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIImageView *tempImageView = (UIImageView *)[window viewWithTag:1001003];
    
    return tempImageView;
}

// 让UIImageView在UIScrollView缩放后居中显示
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIImageView *tempImageView = (UIImageView *)[window viewWithTag:1001003];
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    tempImageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - Button Events
- (void)selectButtonClick:(UIButton *)button
{
    button.selected = !button.selected;
}

#pragma mark - 单击、双击手势
- (void)handleSingleTapgesture:(UITapGestureRecognizer *)tap
{
    _doubleTap = NO;
    [self performSelector:@selector(hide) withObject:nil afterDelay:0.2];
}

- (void)hide
{
    if (_doubleTap) return;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *backgroundView = [window viewWithTag:1001001];
    UIScrollView *tempScroll = (UIScrollView *)[window viewWithTag:1001002];
    UIImageView *tempImageView = (UIImageView *)[window viewWithTag:1001003];
    
    UIButton *btn = (UIButton *)[window viewWithTag:1001004];
    
    if (_isShow) {
        if (_blk) {
            _blk(btn.selected);
        }
        
    }
    
    
    [UIView animateWithDuration:0.2 animations:^{
        
        backgroundView.alpha = 0;
        
    }completion:^(BOOL finished) {
        
        [tempImageView removeFromSuperview];
        [tempScroll removeFromSuperview];
        [backgroundView removeFromSuperview];
        [btn removeFromSuperview];
        
    }];
    
    tempImageView = nil;
    tempScroll = nil;
    backgroundView = nil;
    btn = nil;
    
    _doubleTap = NO;
    
}

- (void)handleDobleTapguesture:(UITapGestureRecognizer *)tap
{
    _doubleTap = YES;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIScrollView *tempScroll = (UIScrollView *)[window viewWithTag:1001002];
    UIImageView *tempImageView = (UIImageView *)[window viewWithTag:1001003];
    
    CGPoint touchPoint = [tap locationInView:tempImageView];
    if (tempScroll.zoomScale == tempScroll.maximumZoomScale) {
        [tempScroll setZoomScale:tempScroll.minimumZoomScale animated:YES];
    } else {
        [tempScroll zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
    }
}


- (void)showImages:(NSArray *)images index:(NSInteger)index block:(SelectBlock)block
{
    
}


@end
