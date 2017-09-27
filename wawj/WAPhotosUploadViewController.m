//
//  WAPhotosUploadViewController.m
//  wawj
//
//  Created by ruiyou on 2017/9/20.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAPhotosUploadViewController.h"
#import "PhotoCell.h"
#import "WANewPhotosViewController.h"
#import <MJRefresh.h>
#import "PhotoItem.h"
#import <UIImageView+WebCache.h>
#import "NSDictionary+Util.h"
#import "WAPhotosShowViewController.h"
#import "WANewPhotosViewController.h"
#import "ZLPhotoActionSheet.h"
#import "UpYun.h"
#import "UpYunFormUploader.h"
#import "UpYunBlockUpLoader.h"
#import <UMSocialCore/UMSocialCore.h>

@interface WAPhotosUploadViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,WANewPhotosViewControllerDelegate,WAPhotosShowViewControllerDelegate>

@property(nonatomic,strong)NSMutableArray *dataArr;
@property(nonatomic,strong)NSString *shareUrl;

@property(nonatomic,strong)UIView *hudView;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headImg;
@property (weak, nonatomic) IBOutlet UILabel *headTitle;
@property (weak, nonatomic) IBOutlet UILabel *dateLab;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *zanBtn;
@property (weak, nonatomic) IBOutlet UILabel *zanName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareContant;

@end

@implementation WAPhotosUploadViewController

-(void)getZanData {
    
    NSDictionary *model = @{@"album_id": self.photosItem.albumId};
    
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P2107" andModel:model];
    
    __weak __typeof__(self) weakSelf = self;
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        
        NSString *code = data[@"code"];
        if ([code isEqualToString:@"0000"]) {
            
            NSDictionary *dict = data[@"body"];
            
            if ([dict[@"isZan"] isEqualToString:@"1"]) {
                
                strongSelf.zanBtn.selected = YES;
            }else {
                strongSelf.zanBtn.selected = NO;
            }
        
            if (!dict[@"zanList"]) {
                strongSelf.zanName = [dict[@"zanList"] firstObject][@"userName"];
            }
            
        }
        
    } fail:^(NSError *error) {
        
//        __strong __typeof__(weakSelf) strongSelf = weakSelf;
//
//        [strongSelf showAlertViewWithTitle:@"提示" message:@"网络请求失败" buttonTitle:@"确定" clickBtn:^{
//
//        }];
        
    }];
    
}

- (IBAction)clickShareWXFriend:(UITapGestureRecognizer *)sender {
    
    [self shareWebPageToPlatformType:UMSocialPlatformType_WechatSession];
    
}
- (IBAction)clickWXFriends:(UITapGestureRecognizer *)sender {
    [self shareWebPageToPlatformType:UMSocialPlatformType_WechatTimeLine];
}
- (IBAction)clickQQFriend:(UITapGestureRecognizer *)sender {
    [self shareWebPageToPlatformType:UMSocialPlatformType_QQ];
}
- (IBAction)clickQZone:(UITapGestureRecognizer *)sender {
    [self shareWebPageToPlatformType:UMSocialPlatformType_Qzone];
}

- (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType
{
    
    return;
    
//    if (!self.shareUrl) {
//        [MBProgressHUD showMessage:nil];
//        self.shareUrl = @"request";
//        [self sharePhotosData];
//
//        return;
//    }
    
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建网页内容对象
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:@"我爱我家" descr:@"相册" thumImage:[UIImage imageNamed:@"hzph"]];
    //设置网页地址
    shareObject.webpageUrl =self.shareUrl;
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            NSLog(@"************Share fail with error %@*********",error);
        }else{
            NSLog(@"response data is %@",data);
        }
    }];
}

-(void)initView {
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"上传"] style:UIBarButtonItemStyleDone target:self action:@selector(clickShare)];
    [rightItem setTintColor:HEX_COLOR(0x666666)];
    [rightItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.title = self.photosItem.title;
    
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
    UINib *cellNib=[UINib nibWithNibName:@"PhotoCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:@"PhotoCell"];
    
    
    [self.headImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@!HeaderApply",self.photosItem.coverUrl]] placeholderImage:nil];
    
//    self.headTitle.text = self.photosItem.author;
    
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"MM月dd日 HH:mm"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[self.photosItem.updateTime doubleValue]];
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:confromTimesp];
    self.dateLab.text = currentDateStr;
    
    [self.zanBtn setBackgroundImage:[UIImage imageNamed:@"zanLight"] forState:UIControlStateSelected];
    [self.zanBtn setBackgroundImage:[UIImage imageNamed:@"zanGray"] forState:UIControlStateNormal];

}

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)clickShare {

    self.shareContant.constant = self.shareContant == 0 ? 81 : 0;
 
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.dataArr = [@[] mutableCopy];
    [self initView];
    
    [self  getZanData];
    
    [MBProgressHUD showMessage:nil];
    [self  getPhotosData];
    
}

- (IBAction)clickUploadBtn:(UIButton *)sender {
    
    ZLPhotoActionSheet *actionSheet = [[ZLPhotoActionSheet alloc] init];
    //设置照片最大预览数
    actionSheet.maxPreviewCount = 100;
    //设置照片最大选择数
    actionSheet.maxSelectCount = 25;
    actionSheet.sender = self;
    
    __weak __typeof__(self) weakSelf = self;
    [actionSheet setSelectImageBlock:^(NSArray<UIImage *> * _Nonnull images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
        //your codes
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [strongSelf uploadImage:images];
        
    }];
    
    [actionSheet showPhotoLibrary];
    
}


-(void)uploadImage:(NSArray *)images {
    
    NSMutableArray *photoLists = [@[] mutableCopy];
    
    NSArray *imageArr = [[NSArray alloc] initWithArray:images];
    if([AFNetworkReachabilityManager sharedManager].isReachable){ //----有网络

        [self hudShow:[NSString stringWithFormat:@"正在上传(0/%ld)...",images.count]];
        
        dispatch_queue_t queue = dispatch_queue_create("com.wawj.www", DISPATCH_QUEUE_PRIORITY_DEFAULT);
        dispatch_async( queue, ^{
            
//            dispatch_group_t group = dispatch_group_create();
            
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
            for (int i = 0; i < images.count+1; i++)
            {
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                
                if (i >= imageArr.count && photoLists.count > 0) {
                    
                    NSDictionary *model = @{@"albumId":     self.photosItem.albumId,
                                            @"photo_List": photoLists};
                    
                    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P2103" andModel:model];
                    __weak __typeof__(self) weakSelf = self;
                    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
                        __strong __typeof__(weakSelf) strongSelf = weakSelf;
                        dispatch_semaphore_signal(semaphore);
                        
                        NSString *code = data[@"code"];
                        NSString *desc = data[@"desc"];
                        if ([code isEqualToString:@"0000"]) {
                            
                            //[view removeFromSuperview];
                            [strongSelf getPhotosList];
                            
                        } else {
                            
                            [strongSelf showAlertViewWithTitle:@"提示" message:desc buttonTitle:@"确定" clickBtn:^{
                                
                            }];
                            
                        }
                        
                    } fail:^(NSError *error) {
                        
                        __strong __typeof__(weakSelf) strongSelf = weakSelf;
                        [strongSelf showAlertViewWithTitle:@"提示" message:@"网络请求失败" buttonTitle:@"确定" clickBtn:^{
                            
                        }];
                        
                        dispatch_semaphore_signal(semaphore);
                    }];
                    
                } else {
                    
                    NSData *fileData = UIImageJPEGRepresentation(imageArr[i], 1);
                    //图片命名
                    NSDate *currentDate = [NSDate date];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
                    NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
                    
                    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
                    NSString *imgName=[NSString stringWithFormat:@"%@/%@%d/%@.jpeg",self.photosItem.albumId, currentDateString,i,userInfo[@"userId"]];

                    UpYunFormUploader *up = [[UpYunFormUploader alloc] init];
                    NSString *bucketName = @"wawj-test";
                    
                    __weak __typeof__(self) weakSelf = self;
                    [up uploadWithBucketName:bucketName
                                    operator:@"wawj2017"
                                    password:@"1+1=2yes"
                                    fileData:fileData
                                    fileName:nil
                                     saveKey:imgName
                             otherParameters:nil
                                     success:^(NSHTTPURLResponse *response,NSDictionary *responseBody) {  //上传成功
                                         __strong __typeof__(weakSelf) strongSelf = weakSelf;
                                         
                                         NSString *photoUrl = [NSString stringWithFormat:@"%@/%@",HTTP_IMAGE,imgName];
                                         NSDictionary *photos = @{@"photo_url":photoUrl, @"photoSize":responseBody[@"file_size"], @"photoWidth":responseBody[@"image-width"], @"photoHeight":responseBody[@"image-height"]};
                                         [photoLists addObject:photos];
                                         
                                         [strongSelf hudShow:[NSString stringWithFormat:@"正在上传(%ld/%ld)...",photoLists.count,images.count]];
                                         
                                         
                                         dispatch_semaphore_signal(semaphore);
                                         
                                     }failure:^(NSError *error,NSHTTPURLResponse *response,NSDictionary *responseBody) { //上传失败
                                         
                                     }progress:^(int64_t completedBytesCount,int64_t totalBytesCount) {
                                         
                                     }];
                    
                }
//                dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
            }

        });
        
    
    }else{ //----没有网络
        [self showAlertViewWithTitle:@"提示" message:@"没有网络" buttonTitle:@"确定" clickBtn:^{

        }];
    }
    
    
    
}

- (IBAction)clickEditBtn:(UIButton *)sender {
    
    WANewPhotosViewController *vc = [[WANewPhotosViewController alloc] initWithNibName:@"WANewPhotosViewController" bundle:nil];
    vc.title = @"编辑相册";
    vc.photosItem = self.photosItem;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(void)waNewPhotosViewControllerWithAlbumId:(NSString *)albumId AndTitle:(NSString *)title {
    self.title = title;
    
    [self.delegate waPhotosUploadViewController:self andEditName:title];
    
}

- (IBAction)clickThumbUp:(UIButton *)sender {
    
    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
    
    NSDictionary *model = @{@"album_id": self.photosItem.albumId,
                            @"userName":userInfo[@"userName"]
                            };
    
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P2106" andModel:model];
    
    __weak __typeof__(self) weakSelf = self;
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        
        NSString *code = data[@"code"];
       NSString *desc = data[@"desc"];
        
        if ([code isEqualToString:@"0000"]) {
            
            strongSelf.zanBtn.selected = !strongSelf.zanBtn.selected;
            
        } else {
            
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            
            [strongSelf showAlertViewWithTitle:@"提示" message:desc buttonTitle:@"确定" clickBtn:^{
                
            }];

            
        }
        
    } fail:^(NSError *error) {
        
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
    
            [strongSelf showAlertViewWithTitle:@"提示" message:@"网络请求失败" buttonTitle:@"确定" clickBtn:^{
    
            }];
        
    }];

}

-(void)getPhotosData {
    
//    // The drop-down refresh
//    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        //Call this Block When enter the refresh status automatically
//        [self getPhotosList];
//    }];
//    
//    // The pull to refresh
//    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//        //Call this Block When enter the refresh status automatically
//        [self getPhotosList];
//    }];
//    
//    [self.collectionView.mj_header beginRefreshing];
    
    [self getPhotosList];
}

-(void)sharePhotosData {
    
    NSDictionary *model = @{@"albumId":     self.photosItem.albumId};
    
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P2105" andModel:model];
    __weak __typeof__(self) weakSelf = self;
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [MBProgressHUD hideHUD];
        
        NSString *code = data[@"code"];
        NSString *desc = data[@"desc"];
        if ([code isEqualToString:@"0000"]) {
            
            strongSelf.shareUrl = data[@"body"][@"album_url"];
            if ([strongSelf.shareUrl isEqualToString: @"request"]) {
            }
            
        } else {
            
            if ([strongSelf.shareUrl isEqualToString: @"request"]) {
                [strongSelf showAlertViewWithTitle:@"提示" message:desc buttonTitle:@"确定" clickBtn:^{
                    
                }];
            }
            
            
        }
        
    } fail:^(NSError *error) {
        [MBProgressHUD hideHUD];
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        
        if ([strongSelf.shareUrl isEqualToString: @"request"]) {
            [strongSelf showAlertViewWithTitle:@"提示" message:@"分享失败" buttonTitle:@"确定" clickBtn:^{
                
            }];
        }
        
        
    }];
    
}

#pragma -mark 相册列表
- (void)getPhotosList {

    
    NSDictionary *model = @{@"albumId":     self.photosItem.albumId,
                            @"lastestTime": @""};
    
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P2104" andModel:model];
    __weak __typeof__(self) weakSelf = self;
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [MBProgressHUD hideHUD];
        
        [strongSelf hideHud];
        
        NSString *code = data[@"code"];
        NSString *desc = data[@"desc"];
        if ([code isEqualToString:@"0000"]) {
            
            if (![data[@"body"][@"photoList"] isKindOfClass:[NSNull class]]) {
                
                [strongSelf.dataArr removeAllObjects];
                
                for (NSDictionary *dict in data[@"body"][@"photoList"]) {
                    
                    NSDictionary *transDict = [dict transforeNullValueInSimpleDictionary];
                    
                    PhotoItem *item = [[PhotoItem alloc] init];
                    item.createTime = transDict[@"createTime"];
                    item.photoHeight = transDict[@"photoHeight"];
                    item.photoId = transDict[@"photoId"];
                    item.photoSize = transDict[@"photoSize"];
                    item.photoUrl = transDict[@"photoUrl"];
                    item.photoWidth = transDict[@"photoWidth"];
                    
                    [self.dataArr addObject:item];
                    
                }
                
                [self.collectionView reloadData];
                
            }
            
            
        } else {
            
            [strongSelf showAlertViewWithTitle:@"提示" message:desc buttonTitle:@"确定" clickBtn:^{
                
            }];
            
        }
        
    } fail:^(NSError *error) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [strongSelf showAlertViewWithTitle:@"提示" message:@"网络请求失败" buttonTitle:@"确定" clickBtn:^{
            
        }];
        
    }];
    
}

-(void)waPhotosShowViewControllerWithDelPhotoIndex:(NSInteger)photoIndex {
    
    [self delPhoto:photoIndex];
    
}

-(void)delPhoto:(NSInteger)photoIndex {
    
    PhotoItem *item = self.dataArr[photoIndex];
    [self.dataArr removeObjectAtIndex:photoIndex];
    [self.collectionView reloadData];
    
    NSDictionary *model = @{@"album_id":self.photosItem.albumId,
                            @"photoId":item.photoId};
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P2108" andModel:model];
    
//    __weak __typeof__(self) weakSelf = self;
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
        
//        __strong __typeof__(weakSelf) strongSelf = weakSelf;
//
//        NSString *code = data[@"code"];
//        if ([code isEqualToString:@"0000"]) {
//
//            NSDictionary *dict = data[@"body"];
//
//            if ([dict[@"isZan"] isEqualToString:@"1"]) {
//
//                strongSelf.zanBtn.selected = YES;
//            }else {
//                strongSelf.zanBtn.selected = NO;
//            }
//
//            if (!dict[@"zanList"]) {
//                strongSelf.zanName = [dict[@"zanList"] firstObject][@"userName"];
//            }
//
//        }
        
    } fail:^(NSError *error) {
        
        //        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        //
        //        [strongSelf showAlertViewWithTitle:@"提示" message:@"网络请求失败" buttonTitle:@"确定" clickBtn:^{
        //
        //        }];
        
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
    
    PhotoCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    
    PhotoItem *item = self.dataArr[indexPath.row];
//    cell.titleLab.text= item.title;
//    
//    //实例化一个NSDateFormatter对象
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    //设定时间格式,这里可以设置成自己需要的格式
//    [dateFormatter setDateFormat:@"MM月dd日 HH:mm:ss"];
//    
//    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:1296035591];
//    //用[NSDate date]可以获取系统当前时间
//    NSString *currentDateStr = [dateFormatter stringFromDate:confromTimesp];
//    
//    cell.timeLab.text = [NSString stringWithFormat:@"%@张  %@",item.nums, currentDateStr];
    
    [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@!PhotoThumb50",item.photoUrl]] placeholderImage:[UIImage imageNamed:@""]];
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
    return CGSizeMake(100, 100);
}

//cell的点击事件
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    WAPhotosShowViewController *vc = [[WAPhotosShowViewController alloc] initWithNibName:@"WAPhotosShowViewController" bundle:nil];
    vc.photoItemArr = self.dataArr;
    vc.photosTitle = self.title;
    vc.photoIndex = indexPath.row;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
    
}



-(void)hudShow:(NSString *)text {
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        
        if (!strongSelf.hudView) {
            strongSelf.hudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 120)];
            strongSelf.hudView.layer.masksToBounds = YES;
            strongSelf.hudView.layer.cornerRadius = 5.0f;
            strongSelf.hudView.backgroundColor = [UIColor darkGrayColor];
            strongSelf.hudView.alpha = 0.8;
            strongSelf.hudView.center = self.view.center;
            
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(40, 15, 30, 30)];
            indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
            [indicator startAnimating];
            
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 150, 30)];
            lab.textAlignment = NSTextAlignmentCenter;
            lab.textColor = [UIColor whiteColor];
            lab.font = [UIFont systemFontOfSize:16];
            lab.tag = 100;
            lab.text = text;//[NSString stringWithFormat:@"正在上传(%ld/%ld)...",images.count,images.count];
            
            [strongSelf.hudView addSubview:indicator];
            [strongSelf.hudView addSubview:lab];
            
            [[UIApplication sharedApplication].keyWindow addSubview:strongSelf.hudView];
            
        } else {
            
            UILabel *lab = [strongSelf.hudView viewWithTag:100];
            lab.text = text;
        }
        
    });
}

-(void)hideHud {
    
    if (self.hudView) {
        [self.hudView removeFromSuperview];
        self.hudView = nil;
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
