//
//  WAGuideViewController.m
//  wawj
//
//  Created by ruiyou on 2017/7/5.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAGuideViewController.h"
#import "WABindIphoneViewController.h"
#import "AppDelegate.h"
#import "WANewInterfaceViewController.h"
#import "WAOldInterfaceViewController.h"

@interface WAGuideViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *enterBtn;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation WAGuideViewController


- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

-(void)initViews {
    self.scrollView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    NSArray *imageArr = @[@"guideOne",@"guideTwo",@"guideThree"];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width*imageArr.count, 0);
    for (NSInteger i = 0; i < 3; i++) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*i, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
        imgView.image = [UIImage imageNamed:imageArr[i]];
        [self.scrollView addSubview:imgView];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self initViews];
    
    [self.view bringSubviewToFront:self.pageControl];
     [self.view bringSubviewToFront:self.enterBtn];
}
- (IBAction)clickEnterApp:(id)sender {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if ([CoreArchive boolForKey:INTERFACE_NEW]) {
        
        WANewInterfaceViewController *vc = [[WANewInterfaceViewController alloc] initWithNibName:@"WANewInterfaceViewController" bundle:nil];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        appDelegate.window.rootViewController = nav;
        
    } else {
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WAOldInterfaceViewController *vc = [sb instantiateViewControllerWithIdentifier:@"WAOldInterfaceViewController"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        appDelegate.window.rootViewController = nav;
        
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    

//    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    WABindIphoneViewController *vc = [sb instantiateViewControllerWithIdentifier:@"WABindIphoneViewController"];
//
//    [self.navigationController pushViewController:vc animated:YES];
    
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSInteger page = scrollView.contentOffset.x/SCREEN_WIDTH;
    NSLog(@"page = %ld", page);
    if (page == 2) {
        self.pageControl.hidden = YES;
        self.enterBtn.hidden = NO;
    } else {
        self.pageControl.hidden = NO;
        self.enterBtn.hidden = YES;
        self.pageControl.currentPage = page;
    }
  
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
