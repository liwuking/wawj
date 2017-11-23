//
//  WACommonlyAPPViewController.m
//  wawj
//
//  Created by ruiyou on 2017/8/7.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WACommonlyAPPViewController.h"
#import "WAAppCollectionViewCell.h"
#import "WAAppAddCollectionViewCell.h"
#import "WAAppListViewController.h"
#import "AppItem.h"
@interface WACommonlyAPPViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray *dataArr;

@end

@implementation WACommonlyAPPViewController

-(void)initView {
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.title = @"常用应用";
    
    /*
     *这是重点 必须注册cell
     */
    //这种是xib建的cell 需要这么注册
    UINib *cellNib=[UINib nibWithNibName:@"WAAppCollectionViewCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:@"WAAppCollectionViewCell"];
    UINib *cellAddNib=[UINib nibWithNibName:@"WAAppAddCollectionViewCell" bundle:nil];
    [_collectionView registerNib:cellAddNib forCellWithReuseIdentifier:@"WAAppAddCollectionViewCell"];

}

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.dataArr = [@[] mutableCopy];
    if ([CoreArchive arrForKey:USER_APP_ARR]) {
        NSArray *selectedAppDictArr = [CoreArchive arrForKey:USER_APP_ARR];
        
        for (NSDictionary *subDict in selectedAppDictArr) {
            
            AppItem *item = [[AppItem alloc] init];
            item.appDownloadUrl = subDict[@"appDownloadUrl"];
            item.appIcoUrl = subDict[@"appIcoUrl"];
            item.appName = subDict[@"appName"];
            item.createTime = subDict[@"createTime"];
            item.channel = subDict[@"channel"];
            item.mId = subDict[@"id"];
            [self.dataArr addObject:item];
        }
    }
    
    [self initView];
    
}

//一共有多少个组
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

//每一组有多少个cell
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArr.count+3;
}

//每一个cell是什么
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger addIndex = self.dataArr.count ? self.dataArr.count+2 : 2;
    if (indexPath.row == addIndex) {
        WAAppAddCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"WAAppAddCollectionViewCell" forIndexPath:indexPath];
        return cell;
    } else {
        
        if (0 == indexPath.row) {
            WAAppCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"WAAppCollectionViewCell" forIndexPath:indexPath];
            cell.titleLab.text = @"手机系统";
            cell.headImageView.image = [UIImage imageNamed:@"icon_setting_system"];
            return cell;
        } else if (1 == indexPath.row) {
            WAAppCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"WAAppCollectionViewCell" forIndexPath:indexPath];
            cell.titleLab.text = @"设置";
            cell.headImageView.image = [UIImage imageNamed:@"icon_setting_app"];
            return cell;
        }else {
            
            AppItem *appItem = self.dataArr[indexPath.row-2];
            WAAppCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"WAAppCollectionViewCell" forIndexPath:indexPath];
            cell.appItem = appItem;
            return cell;
        }
    }
    
}

//每一个分组的上左下右间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

//这个是两行cell之间的间距（上下行cell的间距）
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}


//两个cell之间的间距（同一行的cell的间距）
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}


//定义每一个cell的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(SCREEN_WIDTH/2, SCREEN_WIDTH/2);
}

//cell的点击事件
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //cell被电击后移动的动画
    [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionTop];
    
    NSInteger addIndex = self.dataArr.count ? self.dataArr.count+2 : 2;
    if (indexPath.row == addIndex) {
        
        [self clickCommonAppBtn:nil];
        
    } else {

        
        if (0 == indexPath.row) {
            
            NSURL * url = [NSURL URLWithString:@"App-Prefs:root"];
            if([[UIApplication sharedApplication] canOpenURL:url]) {

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] openURL:url];
                });
                
            }
      
        } else if (1 == indexPath.row) {
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] openURL:url];
                });
            }

        }else {
            AppItem *item = self.dataArr[indexPath.row-2];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:item.appDownloadUrl]];
        }
        
    }
    
}
    
- (IBAction)clickCommonAppBtn:(UIButton *)sender {
    
    WAAppListViewController *vc = [[WAAppListViewController alloc] initWithNibName:@"WAAppListViewController" bundle:nil];
    vc.selectedAppItem = [[NSArray alloc] initWithArray:self.dataArr];
    [self.navigationController pushViewController:vc animated:YES];
    
    __weak __typeof__(self) weakSelf = self;
    vc.wAAppListViewControllerWithAddApp = ^(AppItem *appItem) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        
        if (!appItem.isAdd) {
            [strongSelf.dataArr addObject:appItem];
            [strongSelf.collectionView reloadData];
        }else {
            for (NSInteger i = 0; i < strongSelf.dataArr.count;i++) {
                AppItem *appItemed = strongSelf.dataArr[i];
                if ([appItem.mId isEqualToString:appItemed.mId]) {
                    [strongSelf.dataArr removeObjectAtIndex:i];
                    [strongSelf.collectionView reloadData];
                    break;
                }
            }
        }
        
        NSMutableArray *cacheArr = [@[] mutableCopy];
        for (AppItem *appItem in self.dataArr) {
            
            NSDictionary *dict = @{@"appDownloadUrl":appItem.appDownloadUrl,
                                   @"appIcoUrl":appItem.appIcoUrl,
                                   @"appName":appItem.appName,
                                   @"channel":appItem.channel,
                                   @"createTime":appItem.createTime,
                                   @"id":appItem.mId
                                   };
            [cacheArr addObject:dict];
            
        }
        [CoreArchive setArr:cacheArr key:USER_APP_ARR];
        
    };
}
- (IBAction)clickPhoneBtn:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
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
