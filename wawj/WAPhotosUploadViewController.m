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

@property(nonatomic,assign)NSInteger delIndex;

@property(nonatomic,strong)NSMutableArray *dataArr;
@property(nonatomic,strong)NSString *shareUrl;

@property(nonatomic,strong)UIView *hudView;
@property(nonatomic,strong)NSMutableDictionary *cacheImags;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headImg;
@property (weak, nonatomic) IBOutlet UILabel *headTitle;
@property (weak, nonatomic) IBOutlet UILabel *dateLab;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *zanBtn;
@property (weak, nonatomic) IBOutlet UILabel *zanName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareContant;
@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet UIView *hudShareView;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *uploadBtn;

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
        
            if (![dict[@"zanList"] isKindOfClass:[NSNull class]]) {
                
                NSString *nameText = @"";
                NSMutableArray *texts = [@[] mutableCopy];
                for (NSDictionary *subDict in dict[@"zanList"]) {
                    [texts addObject:subDict[@"userName"]];
                }
                
                texts = (NSMutableArray *)[[texts reverseObjectEnumerator] allObjects];
                
                for (NSString *name in texts) {
                    NSString *str = [nameText isEqualToString:@""]? name:[NSString stringWithFormat:@"、%@", name];
                    nameText = [nameText stringByAppendingString:str];
                }
                
                strongSelf.zanName.text = nameText;
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
     [self hideShareHudView];
    [self shareWebPageToPlatformType:UMSocialPlatformType_WechatSession];
    
}
- (IBAction)clickWXFriends:(UITapGestureRecognizer *)sender {
     [self hideShareHudView];
    [self shareWebPageToPlatformType:UMSocialPlatformType_WechatTimeLine];
}
- (IBAction)clickQQFriend:(UITapGestureRecognizer *)sender {
     [self hideShareHudView];
    [self shareWebPageToPlatformType:UMSocialPlatformType_QQ];
}
- (IBAction)clickQZone:(UITapGestureRecognizer *)sender {
     [self hideShareHudView];
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
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"转发"] style:UIBarButtonItemStyleDone target:self action:@selector(clickShare)];
    [rightItem setTintColor:HEX_COLOR(0x666666)];
    [rightItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.title = self.photosItem.title;
    
    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
    if ([userInfo[@"userId"] isEqualToNumber:(NSNumber *)self.photosItem.author]) {
        self.editBtn.hidden = NO;
        self.uploadBtn.hidden = NO;
        self.headTitle.text = userInfo[@"userName"];
        
        if (![userInfo[@"headUrl"] isKindOfClass:[NSNull class]]) {
            [self.headImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@!HeaderApply",userInfo[@"headUrl"]]] placeholderImage:nil];
        }
        
    } else {
        
        self.editBtn.hidden = YES;
        self.uploadBtn.hidden = YES;
        
        NSMutableArray *qimiArr = [CoreArchive arrForKey:USER_QIMI_ARR];
        for (NSDictionary *dict in qimiArr) {
            
            NSLog(@"dict: %@", dict);
            if ([dict[@"qinmiUser"] isEqualToNumber:(NSNumber *)self.photosItem.author]) {
                if (![dict[@"qinmiUser"] isKindOfClass:[NSString class]]) {
                    self.headTitle.text = dict[@"qinmiName"];
                }
                
                if (![dict[@"headUrl"] isKindOfClass:[NSNull class]]) {
                    [self.headImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@!HeaderApply",dict[@"headUrl"]]] placeholderImage:nil];
                }
            }
  
        }
    }
    
    
    
    
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

-(void)hideShareHudView {
    
    [UIView animateWithDuration:0.2 animations:^{
        self.hudShareView.hidden = YES;
        self.shareView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
        
    }];
}
- (IBAction)clickShareHudView:(id)sender {
    
    [self hideShareHudView];
   
}

-(void)clickShare {

    
    
    [UIView animateWithDuration:0.2 animations:^{
         //self.shareContant.constant = self.shareContant.constant == 0 ? -81 : 0;
        self.hudShareView.hidden = NO;
        self.shareView.frame = CGRectMake(0, SCREEN_HEIGHT-81, SCREEN_WIDTH, SCREEN_HEIGHT);
        
    }];
 
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.cacheImags = [@{} mutableCopy];
    self.delIndex = -1;
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
    actionSheet.maxSelectCount = 25 - self.dataArr.count;
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

    NSMutableArray *imageArr = [[NSMutableArray alloc] initWithArray:images];
    if([AFNetworkReachabilityManager sharedManager].isReachable){ //----有网络

        [self hudShow:[NSString stringWithFormat:@"正在上传(0/%ld)...",images.count]];
        
        dispatch_queue_t queue = dispatch_queue_create("com.wawj.www", DISPATCH_QUEUE_PRIORITY_DEFAULT);
        dispatch_async( queue, ^{

            dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
            for (int i = 0; i < imageArr.count+1; i++)
            {
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                
                if (i >= imageArr.count && photoLists.count > 0) {
                    
                    //上传相册
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
                            
                            //得到相册列表;
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
                    
                    NSData *pngData = UIImagePNGRepresentation(imageArr[i]);
                    //图片命名
                    NSDate *currentDate = [NSDate date];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyyMMdd"];
                    NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
                    
                    //NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
                    NSString *uuid = [NSString stringWithFormat:@"%ld", (long)[currentDate timeIntervalSince1970]];
                    NSString *imgName=[NSString stringWithFormat:@"album/%@/%@%@.png", currentDateString,self.photosItem.albumId,uuid];

                    UpYunFormUploader *up = [[UpYunFormUploader alloc] init];
                    NSString *bucketName = @"wawj-test";
                    
                    __weak __typeof__(self) weakSelf = self;
                    [up uploadWithBucketName:bucketName
                                    operator:@"wawj2017"
                                    password:@"1+1=2yes"
                                    fileData:pngData
                                    fileName:nil
                                     saveKey:imgName
                             otherParameters:nil
                                     success:^(NSHTTPURLResponse *response,NSDictionary *responseBody) {  //上传成功
                                         __strong __typeof__(weakSelf) strongSelf = weakSelf;
                                         
                                         NSString *photoUrl = [NSString stringWithFormat:@"%@/%@",HTTP_IMAGE,imgName];
                                         NSDictionary *photos = @{@"photo_url":photoUrl, @"photoSize":responseBody[@"file_size"], @"photoWidth":responseBody[@"image-width"], @"photoHeight":responseBody[@"image-height"]};
                                         [photoLists addObject:photos];
                                         
                                         [strongSelf.cacheImags setObject:pngData forKey:photoUrl];
                                         
                                         [strongSelf hudShow:[NSString stringWithFormat:@"正在上传(%ld/%ld)...",photoLists.count,imageArr.count]];
                                         
                                         
                                         dispatch_semaphore_signal(semaphore);
                                         
                                     }failure:^(NSError *error,NSHTTPURLResponse *response,NSDictionary *responseBody) { //上传失败
                                         __strong __typeof__(weakSelf) strongSelf = weakSelf;
                                         NSLog(@"上传失败: %ld", strongSelf.cacheImags.count);
                                         
                                         //[strongSelf.cacheImags removeAllObjects];
                                         [strongSelf hideHudWithError:@"上传失败"];
                                         [imageArr removeAllObjects];
                                         
                                         dispatch_semaphore_signal(semaphore);
                                         
                                     }progress:^(int64_t completedBytesCount,int64_t totalBytesCount) {
                                         
                                     }];
                    
                }
            }

        });
        
    
    }else{ //----没有网络
        [self showAlertViewWithTitle:@"提示" message:@"没有网络" buttonTitle:@"确定" clickBtn:^{

        }];
    }
    
    
    
}

-(void)saveImage:(UIImage *)image andImagePath:(NSString *)imagePath {

  NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
  NSString *uniqueSuffix = [NSString stringWithFormat:@"uploadImg/%@",imagePath];
  NSString *path = [documentsDirectory stringByAppendingString:uniqueSuffix];

  NSData *pngData = UIImagePNGRepresentation(image);
  
  [pngData writeToFile:path atomically:YES]; // atomically is a bit safer, but slower
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//
//    [fileManager createFileAtPath:path contents:pngData attributes:nil];
//
//    [fileManager contentsOfDirectoryAtPath:path error:nil];

}

-(UIImage *)getImageFromFileManagerWithImagePath:(NSString *)imagePath {

    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *uniqueSuffix = [NSString stringWithFormat:@"uploadImg/%@",imagePath];
    NSString *path = [documentsDirectory stringByAppendingString:uniqueSuffix];

    UIImage *imge = [UIImage imageWithContentsOfFile:path];
   return   imge;

}

- (IBAction)clickEditBtn:(UIButton *)sender {
    
    WANewPhotosViewController *vc = [[WANewPhotosViewController alloc] initWithNibName:@"WANewPhotosViewController" bundle:nil];
    vc.photosItem = self.photosItem;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma -mark WANewPhotosViewControllerDelegate

-(void)waNewPhotosViewControllerWithAlbumId:(NSString *)albumId AndRefreshTitle:(NSString *)title {
    
    self.title = title;
    self.photosItem.title = title;
    [self.delegate waPhotosUploadViewController:self andRefreshName:self.photosItem];
    
}

- (IBAction)clickThumbUp:(UIButton *)sender {
    
    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
    
    NSDictionary *model = @{@"album_id": self.photosItem.albumId,
                            @"userName":userInfo[@"userName"]
                            };
    
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P2106" andModel:model];
    [MBProgressHUD showMessage:nil];
    __weak __typeof__(self) weakSelf = self;
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [MBProgressHUD hideHUD];
        NSString *code = data[@"code"];
       NSString *desc = data[@"desc"];
        
        if ([code isEqualToString:@"0000"]) {
            
            strongSelf.zanBtn.selected = !strongSelf.zanBtn.selected;
            NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
            
            if (strongSelf.zanBtn.selected) {
                
                if ([strongSelf.zanName.text isEqualToString:@""]) {
                    strongSelf.zanName.text = userInfo[@"userName"];
                }else {
                strongSelf.zanName.text = [NSString stringWithFormat:@"%@、%@",userInfo[@"userName"],strongSelf.zanName.text];
                }
                
            }else {
                
                NSMutableArray *arr = [NSMutableArray arrayWithArray:[strongSelf.zanName.text componentsSeparatedByString:@"、"]];
                NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
                [arr removeObject:userInfo[@"userName"]];
                NSString *nameText = @"";
                for (NSString *name in arr) {
                    NSString *str = [nameText isEqualToString:@""]? name:[NSString stringWithFormat:@"、%@", name];                    nameText = [nameText stringByAppendingString:str];
                    
                }
                
                strongSelf.zanName.text = nameText;
                
                
            }
  
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
                for (NSDictionary *dict  in data[@"body"][@"photoList"]) {
                    
                    NSDictionary *transDict = [dict transforeNullValueInSimpleDictionary];
                    
                    PhotoItem *item = [[PhotoItem alloc] init];
                    item.createTime = transDict[@"createTime"];
                    item.photoHeight = transDict[@"photoHeight"];
                    item.photoId = transDict[@"photoId"];
                    item.photoSize = transDict[@"photoSize"];
                    item.photoUrl = transDict[@"photoUrl"];
                    item.photoWidth = transDict[@"photoWidth"];
                    
                    [strongSelf.dataArr addObject:item];
                    
                }
                
                if (!strongSelf.cacheImags.count) {
                    [strongSelf.collectionView reloadData];
                } else {
                    
                    NSMutableArray *indexPaths = [@[] mutableCopy];
                    
                    for (NSInteger i = 0; i < strongSelf.cacheImags.count; i++) {
                        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    }
                    
                    [UIView animateWithDuration:0.5 animations:^{
                        [strongSelf.collectionView insertItemsAtIndexPaths:indexPaths];
                    }];
                    
                }
                
                if (strongSelf.dataArr.count >= 25) {
                    strongSelf.uploadBtn.hidden = YES;
                }
                
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
    
    self.delIndex = photoIndex;
    
}

-(void)viewDidAppear:(BOOL)animated {
    
    if (-1 != self.delIndex) {
        [self delPhoto:self.delIndex];
        self.delIndex = -1;
    }
    
}

-(void)delPhoto:(NSInteger)photoIndex {
    
    PhotoItem *item = self.dataArr[photoIndex];
    [self.dataArr removeObjectAtIndex:photoIndex];
    
    [UIView beginAnimations:nil context:nil]; // 开始动画
    [UIView setAnimationDuration:0.5]; // 动画时长
    
    [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:photoIndex inSection:0]]];
    
    [UIView commitAnimations]; // 提交动画
    
    
    NSDictionary *model = @{@"album_id":self.photosItem.albumId,
                            @"photoId":item.photoId};
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P2108" andModel:model];
    
    [CLNetworkingManager postNetworkRequestWithUrlString:KMain_URL parameters:params isCache:NO succeed:^(id data) {
        
        
    } fail:^(NSError *error) {

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
    
    if ([self.cacheImags.allKeys containsObject:item.photoUrl]) {
        UIImage *img =  [[UIImage alloc] initWithData:self.cacheImags[item.photoUrl]];
        cell.headImageView.image = img;
        
        [self.cacheImags removeObjectForKey:item.photoUrl];
    } else {
        
        [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@!PhotoThumb50",item.photoUrl]] placeholderImage:[UIImage imageNamed:@""]];
    }
 
//    if ([self.cacheImags.allKeys containsObject:[item.photoUrl stringByAppendingString:@"/image.png"]]) {
//        UIImage *img =  [self getImageFromFileManagerWithImagePath:item.photoUrl];//[[UIImage alloc] initWithData:self.cacheImags[@"item.photoUrl"]];
//        cell.headImageView.image = img;
//    } else {
//
//        [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@!PhotoThumb50",item.photoUrl]] placeholderImage:[UIImage imageNamed:@""]];
//    }
    
    return cell;
    
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 4;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 4;
}
//每一个分组的上左下右间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(4, 4, 4, 4);
}

//定义每一个cell的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((SCREEN_WIDTH-20)/3, 110);
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
            
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(60, 15, 30, 30)];
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
    
    __weak __typeof__(self) weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (strongSelf.hudView) {
            [strongSelf.hudView removeFromSuperview];
            strongSelf.hudView = nil;
        }
        
    });

}

-(void)hideHudWithError:(NSString *)errorMessage {
    
    __weak __typeof__(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        
        UILabel *lab = [strongSelf.hudView viewWithTag:100];
        lab.text = errorMessage;
        
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (strongSelf.hudView) {
            [strongSelf.hudView removeFromSuperview];
            strongSelf.hudView = nil;
        }
    });
    
    
    
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
