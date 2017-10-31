//
//  WAPhotosShowViewController.m
//  wawj
//
//  Created by ruiyou on 2017/9/20.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAPhotosShowViewController.h"
#import "PhotoItem.h"
#import <UIImageView+WebCache.h>
#import "stringUtil.h"
@interface WAPhotosShowViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation WAPhotosShowViewController

-(void)initView {
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(clickDel)];
    [rightItem setTintColor:HEX_COLOR(0x666666)];
    [rightItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH*self.photoItemArr.count, 100);
    
    
    self.title = [NSString stringWithFormat:@"%@(%lu/%lu)", self.photosTitle, self.photoIndex+1,(unsigned long)self.photoItemArr.count];
    
}

-(void)viewDidAppear:(BOOL)animated {
    
     NSLog(@"actualSize: %lf %lf", SCREEN_WIDTH,self.scrollView.frame.size.height);
    for (NSInteger i = 0; i < self.photoItemArr.count; i++) {
        
        PhotoItem *item = self.photoItemArr[i];
        
        NSString *thumbUrl = [stringUtil calculateImageRatioWithShowSize:CGSizeMake(SCREEN_WIDTH, self.scrollView.frame.size.height) actualSize:CGSizeMake([item.photoWidth floatValue], [item.photoHeight floatValue]) andPhotoUrl:item.photoUrl];
        NSLog(@"thumbUrl: %@", thumbUrl);
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*i, 0, SCREEN_WIDTH, self.scrollView.frame.size.height)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds = YES;
        [imageView sd_setImageWithURL:[NSURL URLWithString:thumbUrl] placeholderImage:[UIImage imageNamed:@"loadImaging"]];
        
        [self.scrollView addSubview:imageView];
    }
    
    [self.scrollView setContentOffset:CGPointMake(SCREEN_WIDTH*self.photoIndex, 0)];
}

-(void)clickDel {
    
    NSInteger index = self.scrollView.contentOffset.x/SCREEN_WIDTH;
    __weak __typeof__(self) weakSelf = self;
    [self showAlertViewWithTitle:@"" message:@"删除照片后, 大家就看不到了" cancelButtonTitle:@"取消" clickCancelBtn:^{
        
    } otherButtonTitles:@"确定" clickOtherBtn:^{
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        
        [strongSelf.delegate waPhotosShowViewControllerWithDelPhotoIndex:index];
        [strongSelf.navigationController popViewControllerAnimated:YES];
        
        
    }];
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    self.title = [NSString stringWithFormat:@"%@(%lu/%lu)", self.photosTitle, (unsigned long)(self.scrollView.contentOffset.x/SCREEN_WIDTH+1),(unsigned long)self.photoItemArr.count];
    
}

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initView];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
