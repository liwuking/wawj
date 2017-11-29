//
//  WAReplaceUIViewController.m
//  wawj
//
//  Created by ruiyou on 2017/8/8.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAReplaceUIViewController.h"
#import "WANewInterfaceViewController.h"
#import "WAOldInterfaceViewController.h"
#import "AppDelegate.h"
@interface WAReplaceUIViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gouX;
@property (weak, nonatomic) IBOutlet UIButton *replaceBtn;
@property(nonatomic,assign)BOOL originInterface;
@end

@implementation WAReplaceUIViewController

-(void)initViews {
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    self.title = @"老年界面";
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.replaceBtn.hidden = YES;
    self.originInterface = [CoreArchive boolForKey:INTERFACE_NEW];
    
    if (self.originInterface) {
        self.replaceBtn.hidden = YES;
        self.gouX.constant = SCREEN_WIDTH-120;
    } else {
        self.replaceBtn.hidden = YES;
        self.gouX.constant = 69;
    }
    
}

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initViews];
    
   
    
}
- (IBAction)clickLeftGes:(UITapGestureRecognizer *)sender {
    
     if (self.gouX.constant != 69) {
         self.replaceBtn.hidden = !self.replaceBtn.hidden;
         self.gouX.constant = 69;
     }
    
}
- (IBAction)clickRightGes:(UITapGestureRecognizer *)sender {
    
    if (self.gouX.constant != SCREEN_WIDTH-120) {
        self.replaceBtn.hidden = !self.replaceBtn.hidden;
        self.gouX.constant = SCREEN_WIDTH-120;
    }
    
}


- (IBAction)clickReplaceBtn:(UIButton *)sender {

    [CoreArchive setBool:!self.originInterface key:INTERFACE_NEW];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!self.originInterface) {
        
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
