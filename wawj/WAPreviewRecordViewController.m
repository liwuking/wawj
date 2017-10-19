//
//  WAPreviewRecordViewController.m
//  wawj
//
//  Created by ruiyou on 2017/10/19.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAPreviewRecordViewController.h"
#import <UIImageView+WebCache.h>
#import "CircularView.h"
@interface WAPreviewRecordViewController ()<CircularViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIButton *startStopBtn;
@property (weak, nonatomic) IBOutlet CircularView *cicularView;

@property (weak, nonatomic) IBOutlet UILabel *recordDateLab;
@end

@implementation WAPreviewRecordViewController

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initViews {
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    self.title = @"预览闹钟";
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@!HeaderFamily",self.headUrl]] placeholderImage:[UIImage imageNamed:@"头像设置"] options:SDWebImageRetryFailed completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
    }];
    
    self.recordDateLab.text = self.recordedDate;
    self.cicularView.delegate = self;
    
    [self.startStopBtn setImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
    [self.startStopBtn setImage:[UIImage imageNamed:@"friends"] forState:UIControlStateSelected];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initViews];
    
    
    
}

- (IBAction)clickStartBtn:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.cicularView startCircleWithTimeLength:self.recordedTime];
    } else {
        [self.cicularView endCircle];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.startStopBtn.selected = !self.startStopBtn.selected;
    [self.cicularView startCircleWithTimeLength:self.recordedTime];
}

#pragma -mark CircularViewDelegate

-(void)circularViewStartDraw {
    
}

-(void)circularViewWithProgress:(NSInteger)progress {
    
    
}

-(void)circularViewEndDraw {
    
    self.startStopBtn.selected = !self.startStopBtn.selected;
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
