//
//  WAMyFamilyPhotosViewController.m
//  wawj
//
//  Created by ruiyou on 2017/9/18.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAMyFamilyPhotosViewController.h"
#import "PhotoCollectionViewCell.h"
#import "WANewPhotosViewController.h"
#import <MJRefresh.h>
#import "PhotosItem.h"
#import <UIImageView+WebCache.h>
#import "NSDictionary+Util.h"
#import "WAPhotosUploadViewController.h"

@interface WAMyFamilyPhotosViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,WAPhotosUploadViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray *dataArr;
@property(nonatomic,assign)NSInteger selectIndex;

@end

@implementation WAMyFamilyPhotosViewController

-(void)initView {
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"上传"] style:UIBarButtonItemStyleDone target:self action:@selector(clickUploadImage)];
    [rightItem setTintColor:HEX_COLOR(0x666666)];
    [rightItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.title = @"我家相册";
    
    //此处必须要有创见一个UICollectionViewFlowLayout的对象
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc]init];
    //同一行相邻两个cell的最小间距
    layout.minimumInteritemSpacing = 5;
    //最小两行之间的间距
    layout.minimumLineSpacing = 5;
    
    /*
     *这是重点 必须注册cell
     */
    //这种是xib建的cell 需要这么注册
    UINib *cellNib=[UINib nibWithNibName:@"PhotoCollectionViewCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:@"PhotoCollectionViewCell"];
    
}

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)clickUploadImage {

    WANewPhotosViewController *vc = [[WANewPhotosViewController alloc] initWithNibName:@"WANewPhotosViewController" bundle:nil];
    vc.title = @"新建相册";
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(void)waPhotosUploadViewController:(WAPhotosUploadViewController *)vc andEditName:(NSString *)albumName {
    
    PhotosItem *item = self.dataArr[self.selectIndex];
    item.title = albumName;
    
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.selectIndex inSection:0]]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.dataArr = [@[] mutableCopy];
    [self initView];
    
    [self  getPhotosData];
    
}

-(void)getPhotosData {
    
    // The drop-down refresh
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //Call this Block When enter the refresh status automatically
        [self getPhotosList];
    }];
    
    // The pull to refresh
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        //Call this Block When enter the refresh status automatically
        [self getPhotosList];
    }];
    
    [self.collectionView.mj_header beginRefreshing];
}

#pragma -mark 相册列表
- (void)getPhotosList {
    
    long time = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *timeStamp = [NSString stringWithFormat:@"%ld",time];//1504600817000
    NSDictionary *model = @{@"pageNum":     [NSString stringWithFormat:@"%ld",self.dataArr.count/10+1],
                            @"pageSize":    @"10",
                            @"lastestTime": @""};
    
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P2101" andModel:model];
    
    __weak __typeof__(self) weakSelf = self;
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        
        if ([strongSelf.collectionView.mj_header isRefreshing]) {
            [strongSelf.collectionView.mj_header endRefreshing];
        } else {
            [strongSelf.collectionView.mj_footer endRefreshing];
        }
        
        
        NSString *code = data[@"code"];
        NSString *desc = data[@"desc"];
        if ([code isEqualToString:@"0000"]) {
            
            for (NSDictionary *dict in data[@"body"]) {
                
                NSDictionary *transDict = [dict transforeNullValueInSimpleDictionary];
                
                PhotosItem *item = [[PhotosItem alloc] init];
                item.albumId = transDict[@"albumId"];
                item.albumStyle = transDict[@"albumStyle"];
                item.author = transDict[@"author"];
                item.coverUrl = transDict[@"coverUrl"];
                item.nums = transDict[@"nums"];
                item.title = transDict[@"title"];
                item.updateTime = transDict[@"updateTime"];
                
                [strongSelf.dataArr addObject:item];
                
            }
            
            if (strongSelf.dataArr.count < 50) {
                [strongSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
            }
            
            [strongSelf.collectionView reloadData];
            
        } else {
            
            [strongSelf showAlertViewWithTitle:@"提示" message:desc buttonTitle:@"确定" clickBtn:^{
                
            }];
            
        }
        
    } fail:^(NSError *error) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        
        if ([strongSelf.collectionView.mj_header isRefreshing]) {
            [strongSelf.collectionView.mj_header endRefreshing];
        } else {
            [strongSelf.collectionView.mj_footer endRefreshing];
        }
        //[MBProgressHUD hideHUD];
        
        [strongSelf showAlertViewWithTitle:@"提示" message:@"网络请求失败" buttonTitle:@"确定" clickBtn:^{
            
        }];
        
    }];

}


//一共有多少个组
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

//每一组有多少个cell
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArr.count;
}

//每一个cell是什么
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PhotoCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCollectionViewCell" forIndexPath:indexPath];
    PhotosItem *item = self.dataArr[indexPath.row];
    cell.titleLab.text= item.title;
    
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"MM月dd日 HH:mm"];
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[item.updateTime doubleValue]];
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:confromTimesp];
    
    cell.timeLab.text = [NSString stringWithFormat:@"%@张  %@",item.nums, currentDateStr];
    
    [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:item.coverUrl] placeholderImage:[UIImage imageNamed:@""]];
    return cell;
    
}

//每一个分组的上左下右间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

//定义每一个cell的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(140, 170);
}

//cell的点击事件
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
//    //cell被电击后移动的动画
//    [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionTop];
//    if (self.dataArr.count == indexPath.row) {
//        [self clickPhoneNumber];
//    } else {
//        
//        ContactItem *item = self.dataArr[indexPath.row];
//        
//        [self showAlertViewWithTitle:@"提示" message:[NSString stringWithFormat:@"是否拨打%@的号码",item.name] cancelButtonTitle:@"取消" clickCancelBtn:^{
//            
//        } otherButtonTitles:@"拨打" clickOtherBtn:^{
//            NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",item.phone];
//            //NSLog(@"str======%@",str);
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
//        }];
//    }
    
    PhotosItem *item = self.dataArr[indexPath.row];
    
    WAPhotosUploadViewController *vc = [[WAPhotosUploadViewController alloc] initWithNibName:@"WAPhotosUploadViewController" bundle:nil];
    vc.photosItem = item;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
    
    self.selectIndex = indexPath.row;
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
