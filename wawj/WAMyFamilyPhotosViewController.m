//
//  WAMyFamilyPhotosViewController.m
//  wawj
//
//  Created by ruiyou on 2017/9/18.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAMyFamilyPhotosViewController.h"
#import "WANewPhotosViewController.h"
#import <MJRefresh.h>
#import "PhotosItem.h"
#import <UIImageView+WebCache.h>
#import "NSDictionary+Util.h"
#import "WAPhotosUploadViewController.h"

#import "PhotoCollectionViewCell.h"
#import "PhotoCollectionViewCellNew.h"
#import "PhotoCollectionViewCellNoMe.h"
#import "PhotoCollectionViewCellNoMeNew.h"

@interface WAMyFamilyPhotosViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,WAPhotosUploadViewControllerDelegate,WANewPhotosViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray *dataArr;
//@property(nonatomic,assign)NSInteger selectIndex;

@end

@implementation WAMyFamilyPhotosViewController

-(void)initView {
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"上传"] style:UIBarButtonItemStyleDone target:self action:@selector(clickNewPhotos)];
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
    
    UINib *cellNib2=[UINib nibWithNibName:@"PhotoCollectionViewCellNoMe" bundle:nil];
    [_collectionView registerNib:cellNib2 forCellWithReuseIdentifier:@"PhotoCollectionViewCellNoMe"];
    
    __weak __typeof__(self) weakSelf = self;
    // The drop-down refresh
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //Call this Block When enter the refresh status automatically
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [strongSelf getPhotosList];
    }];
    
    // The pull to refresh
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        //Call this Block When enter the refresh status automatically
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [strongSelf getPhotosList];
    }];
    
}

#pragma -mark WANewPhotosViewControllerDelegate
-(void)waNewPhotosViewControllerWithNewPhotosAlbumId:(NSString *)albumId AndTitle:(NSString *)title {
    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
    
    PhotosItem *item = [[PhotosItem alloc] init];
    item.albumId = albumId;
    item.albumStyle = @"";
    item.author = userInfo[@"userId"];
    item.coverUrl = @"";
    item.nums = @"0";
    item.title = title;
    item.updateTime = @"";
    item.isSelf = YES;
    item.isNew = YES;
    [self.dataArr insertObject:item atIndex:0];
    
    __weak __typeof__(self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [strongSelf.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
    }];
    
}

#pragma -mark WAPhotosUploadViewControllerDelegate
-(void)waPhotosUploadViewController:(WAPhotosUploadViewController *)vc andRefreshName:(PhotosItem *)photosItem {
    
    for (NSInteger i = 0; i < self.dataArr.count; i++) {
         PhotosItem *item = self.dataArr[i];
        if ([item.albumId integerValue] == [photosItem.albumId integerValue]) {
            item.title = photosItem.title;
            
            [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
        }
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.dataArr = [@[] mutableCopy];
    [self initView];
    
    //获取相册列表
    [self.collectionView.mj_header beginRefreshing];
    
}

-(void)photosListCachehandle {
    
    //从本地缓存获取数据
    NSMutableArray *oldPhotoArr = [[NSMutableArray alloc] initWithArray:[CoreArchive arrForKey:USER_PHOTO_ARR]];
    if ([self.collectionView.mj_footer isRefreshing]) {
        
        NSMutableArray *oldPhotoSets = [@[] mutableCopy];
        if ([CoreArchive arrForKey:UNSHOWPHOTOS]) {
            [oldPhotoSets addObjectsFromArray:[CoreArchive arrForKey:UNSHOWPHOTOS]];
        }
        NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
        
        if (oldPhotoArr.count - self.dataArr.count > 0) {
            
            if (oldPhotoArr.count - self.dataArr.count > 10) {
                NSArray *cacheArr = [oldPhotoArr subarrayWithRange:NSMakeRange(self.dataArr.count, 10)];
                for (NSDictionary *dict in cacheArr) {
                    PhotosItem *item = [[PhotosItem alloc] init];
                    item.albumId = dict[@"albumId"];
                    item.albumStyle = dict[@"albumStyle"];
                    item.author = dict[@"author"];
                    item.coverUrl = dict[@"coverUrl"];
                    item.nums = dict[@"nums"];
                    item.title = dict[@"title"];
                    item.updateTime = dict[@"updateTime"];
                    if (![oldPhotoSets containsObject:item.albumId]) {
                        item.isNew = YES;
                    }
                    if ([userInfo[@"userId"] isEqualToValue:(NSNumber *)item.author]) {
                        item.isSelf = YES;
                    }
                    
                    
                    [self.dataArr addObject:item];
                    
                }
                [self.collectionView.mj_footer endRefreshing];
            } else {
                
                NSArray *cacheArr = [oldPhotoArr subarrayWithRange:NSMakeRange(self.dataArr.count, oldPhotoArr.count - self.dataArr.count)];
                for (NSDictionary *dict in cacheArr) {
                    PhotosItem *item = [[PhotosItem alloc] init];
                    item.albumId = dict[@"albumId"];
                    item.albumStyle = dict[@"albumStyle"];
                    item.author = dict[@"author"];
                    item.coverUrl = dict[@"coverUrl"];
                    item.nums = dict[@"nums"];
                    item.title = dict[@"title"];
                    item.updateTime = dict[@"updateTime"];
                    if (![oldPhotoSets containsObject:item.albumId]) {
                        item.isNew = YES;
                    }
                    if ([userInfo[@"userId"] isEqualToValue:(NSNumber *)item.author]) {
                        item.isSelf = YES;
                    }
                    [self.dataArr addObject:item];
                    
                }
                [self.collectionView.mj_footer endRefreshingWithNoMoreData];
            }
            
            [self.collectionView reloadData];
            
        } else {
            
            [self.collectionView.mj_footer endRefreshingWithNoMoreData];
        }
        
    } else {
        
        if ([AFNetworkReachabilityManager sharedManager].isReachable) {
            
            NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
            if (0 == self.dataArr.count) {
                
                if (oldPhotoArr.count > 0) {
                    
                    NSMutableArray *cacheArr = [@[] mutableCopy];
                    
                    if (oldPhotoArr.count > 10) {
                        NSArray *photoArr = [oldPhotoArr subarrayWithRange:NSMakeRange(0, 10)];
                        [cacheArr addObjectsFromArray:photoArr];
                    } else if (oldPhotoArr.count > 0 && oldPhotoArr.count < 10) {
                        NSArray *photoArr = [oldPhotoArr subarrayWithRange:NSMakeRange(0, oldPhotoArr.count)];
                        [cacheArr addObjectsFromArray:photoArr];
                    }
                    
                    for (NSDictionary *dict in cacheArr) {
                        PhotosItem *item = [[PhotosItem alloc] init];
                        item.albumId = dict[@"albumId"];
                        item.albumStyle = dict[@"albumStyle"];
                        item.author = dict[@"author"];
                        item.coverUrl = dict[@"coverUrl"];
                        item.nums = dict[@"nums"];
                        item.title = dict[@"title"];
                        item.updateTime = dict[@"updateTime"];
                        if ([userInfo[@"userId"] isEqualToValue:(NSNumber *)item.author]) {
                            item.isSelf = YES;
                        }
                        
                        [self.dataArr addObject:item];
                        
                    }
                    [self.collectionView.mj_header endRefreshing];
                    [self.collectionView reloadData];
                    
                }
                
            }
            
            
        } else {
            [self.collectionView.mj_header endRefreshing];
            [MBProgressHUD showSuccess:@"网络未开启"];
        }

    }
}


#pragma -mark 存储新增相册标签
-(void)savePhotosShowTag:(NSArray *)oldPhotos{
    
    NSMutableSet *tagDicts;
    if ([CoreArchive arrForKey:UNSHOWPHOTOS]) {
        tagDicts = [NSMutableSet setWithArray:[CoreArchive arrForKey:UNSHOWPHOTOS]];
    } else {
        tagDicts = [[NSMutableSet alloc] init];
    }
    
    NSLog(@"旧标签tagDicts: %@",tagDicts);
    for (NSDictionary *dict in oldPhotos) {
        [tagDicts addObject:dict[@"albumId"]];
    }
    
    NSMutableArray *dataArr = [[NSMutableArray alloc] initWithArray:tagDicts.allObjects];

    NSLog(@"新标签tagDicts: %@",tagDicts);
    [CoreArchive setArr:dataArr key:UNSHOWPHOTOS];

}

#pragma -mark 相册列表
- (void)getPhotosList {
    
    //缓存处理
    [self photosListCachehandle];
    
    if ([self.collectionView.mj_footer isRefreshing]) {
        return;
    }
    
    NSString *lastestTime = @"";
    if ([CoreArchive strForKey:LASTTIME]) {
        lastestTime = [CoreArchive strForKey:LASTTIME];
    }
    NSDictionary *model = @{@"lastestTime": lastestTime};
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
            
            if (![data[@"body"] isKindOfClass:[NSNull class]]) {
                
                NSMutableArray *oldPhotoSets = [@[] mutableCopy];
                if ([CoreArchive arrForKey:UNSHOWPHOTOS]) {
                    [oldPhotoSets addObjectsFromArray:[CoreArchive arrForKey:UNSHOWPHOTOS]];
                }
                NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
                NSMutableArray *photosItemArr = [@[] mutableCopy];
                NSMutableArray *photosCacheArr = [@[] mutableCopy];
                for (NSDictionary *dict in data[@"body"]) {
                    
                    NSDictionary *transDict = [dict transforeNullValueToEmptyStringInSimpleDictionary];
                    
                    PhotosItem *item = [[PhotosItem alloc] init];
                    item.albumId = transDict[@"albumId"];
                    item.albumStyle = transDict[@"albumStyle"];
                    item.author = transDict[@"author"];
                    item.coverUrl = transDict[@"coverUrl"];
                    item.nums = transDict[@"nums"];
                    item.title = transDict[@"title"];
                    item.updateTime = transDict[@"updateTime"];
                    
                    if (oldPhotoSets.count && ![oldPhotoSets containsObject:item.albumId]) {
                        item.isNew = YES;
                    }
                    if ([userInfo[@"userId"] isEqualToValue:(NSNumber *)item.author]) {
                        item.isSelf = YES;
                    }
                    
                    NSDictionary *PhotosDict = @{@"albumId":transDict[@"albumId"],
                                                 @"albumStyle":transDict[@"albumStyle"],
                                                 @"author":transDict[@"author"],
                                                 @"coverUrl":transDict[@"coverUrl"],
                                                 @"nums":transDict[@"nums"],
                                                 @"title":transDict[@"title"],
                                                 @"updateTime":transDict[@"updateTime"]
                                                 };
                    [photosCacheArr addObject:PhotosDict];
                    
                    if (photosItemArr.count < 10) {
                        [photosItemArr addObject:item];
                    }
                    
                    if (photosCacheArr.count == 1) {
                        NSNumber *updateTime = (NSNumber *)item.updateTime;
                        [CoreArchive setStr:[updateTime stringValue] key:LASTTIME];
                    }
                }
                
                [strongSelf.dataArr removeAllObjects];
                [strongSelf.dataArr addObjectsFromArray:photosItemArr];
                //刷新列表
                [strongSelf.collectionView reloadData];
                
                //保存新增标签
                if ([lastestTime isEqualToString:@""]) {
                    [strongSelf savePhotosShowTag:photosCacheArr];
                }
                
                
                //存储相册列表数据
                if(photosCacheArr.count > 0) {
                    
                    if (photosCacheArr.count < 20) {//更新数据小于20条，不清除缓存，反之清除
                        if ([CoreArchive arrForKey:USER_PHOTO_ARR]) {
                            
                            NSMutableArray *oldPhotoArr = [[NSMutableArray alloc] initWithArray:[CoreArchive arrForKey:USER_PHOTO_ARR]];
                            //去重处理
                            for (NSDictionary *dict in oldPhotoArr) {
                                if (![photosCacheArr containsObject:dict]) {
                                    [photosCacheArr addObject:dict];
                                }
                            }
                            
                        } else {
                            
                            NSMutableArray *oldPhotoArr = [[NSMutableArray alloc] initWithArray:[CoreArchive arrForKey:USER_PHOTO_ARR]];
                            [photosCacheArr addObjectsFromArray:oldPhotoArr];
                            
                        }
                        
                    } else {//更新数据大于20条，清除缓存并获取最新50条
                        if (photosCacheArr.count > 50) {
                            [photosCacheArr removeObjectsInRange:NSMakeRange(50, photosCacheArr.count-50)];
                        }
                        
                    }
                    
                    [CoreArchive setArr:photosCacheArr key:USER_PHOTO_ARR];

                }
                
                
            }
      
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
    
    PhotosItem *item = self.dataArr[indexPath.row];
//    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"MM月dd日 HH:mm"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[item.updateTime doubleValue]];
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:confromTimesp];
    
    if (item.isSelf) {
        
        if (item.isNew) {
            PhotoCollectionViewCellNew *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCollectionViewCellNew" forIndexPath:indexPath];
            
            cell.titleLab.text= item.title;
            cell.timeLab.text = [NSString stringWithFormat:@"%@张  %@",item.nums, currentDateStr];
            [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:item.coverUrl] placeholderImage:[UIImage imageNamed:@"familyPhotos"]];
            
            return cell;
        } else {
            PhotoCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCollectionViewCell" forIndexPath:indexPath];
            
            cell.titleLab.text= item.title;
            cell.timeLab.text = [NSString stringWithFormat:@"%@张  %@",item.nums, currentDateStr];
            [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:item.coverUrl] placeholderImage:[UIImage imageNamed:@"familyPhotos"]];
            
            return cell;
        }
        
    } else {
        
        if (item.isNew) {
            PhotoCollectionViewCellNoMeNew *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCollectionViewCellNoMeNew" forIndexPath:indexPath];
            
            cell.titleLab.text= item.title;
            cell.timeLab.text = [NSString stringWithFormat:@"%@张  %@",item.nums, currentDateStr];
            [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:item.coverUrl] placeholderImage:[UIImage imageNamed:@"familyPhotos"]];
            
            return cell;
        } else {
            PhotoCollectionViewCellNoMe *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCollectionViewCellNoMe" forIndexPath:indexPath];
            
            cell.titleLab.text= item.title;
            cell.timeLab.text = [NSString stringWithFormat:@"%@张  %@",item.nums, currentDateStr];
            [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:item.coverUrl] placeholderImage:[UIImage imageNamed:@"familyPhotos"]];
            
            return cell;
        }
        
        
    }
    
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}
//每一个分组的上左下右间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

//定义每一个cell的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (SCREEN_WIDTH-20)/2;
    CGFloat height = (width/140) * 170;
    return CGSizeMake((SCREEN_WIDTH-20)/2, height);
}

//cell的点击事件
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PhotosItem *item = self.dataArr[indexPath.row];
    
    WAPhotosUploadViewController *vc = [[WAPhotosUploadViewController alloc] initWithNibName:@"WAPhotosUploadViewController" bundle:nil];
    vc.photosItem = item;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
    
    
    
    
    if (item.isNew) {
        item.isNew = NO;
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        
        NSMutableArray *tagDicts = [@[] mutableCopy];
        if ([CoreArchive arrForKey:UNSHOWPHOTOS]) {
            [tagDicts addObjectsFromArray:[CoreArchive arrForKey:UNSHOWPHOTOS]];
        }
        [tagDicts addObject:item.albumId];
        
        [CoreArchive setArr:tagDicts key:UNSHOWPHOTOS];
    }
    
}

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)clickNewPhotos {
    
    WANewPhotosViewController *vc = [[WANewPhotosViewController alloc] initWithNibName:@"WANewPhotosViewController" bundle:nil];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
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
