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
#import "UploadPhotoNullView.h"
#import "WAAdvertiseViewController.h"
@interface WAPhotosUploadViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,WANewPhotosViewControllerDelegate,WAPhotosShowViewControllerDelegate,WAUploadPhotoNullViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lineLab;
@property(nonatomic,assign)NSInteger delIndex;

@property(nonatomic,strong)NSMutableArray *dataArr;
@property(nonatomic,strong)NSString *shareUrl;
@property(nonatomic,strong)NSString *shareContent;
@property(nonatomic,strong)NSString *shareTitle;

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


@property(nonatomic,assign)BOOL isChange;

@property(nonatomic,strong)UploadPhotoNullView *uploadPhotoNullView;


@end

@implementation WAPhotosUploadViewController




- (IBAction)clickShareWXFriend:(UITapGestureRecognizer *)sender {
//     [self hideShareHudView];
    [self shareWebPageToPlatformType:UMSocialPlatformType_WechatSession];
    
}
- (IBAction)clickWXFriends:(UITapGestureRecognizer *)sender {
//     [self hideShareHudView];
    [self shareWebPageToPlatformType:UMSocialPlatformType_WechatTimeLine];
}
- (IBAction)clickQQFriend:(UITapGestureRecognizer *)sender {
//     [self hideShareHudView];
    [self shareWebPageToPlatformType:UMSocialPlatformType_QQ];
}
- (IBAction)clickQZone:(UITapGestureRecognizer *)sender {
//     [self hideShareHudView];
    [self shareWebPageToPlatformType:UMSocialPlatformType_Qzone];
}

- (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType
{

    if (self.shareUrl) {
//        NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
        //创建分享消息对象
        UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
        
//        NSString *desc = [NSString stringWithFormat:@"%@创建了YYY相册，快来看啊~",userInfo[USERNAME]];
//        NSString *title = [NSString stringWithFormat:@"邀请你欣赏我的家庭相册“%@相册名称”",userInfo[USERNAME]];
        //创建网页内容对象
        UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:self.shareTitle descr:self.shareContent thumImage:[UIImage imageNamed:@"logo"]];
        //设置网页地址
        shareObject.webpageUrl = self.shareUrl;
        
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
        
        [self hideShareHudView];
    }else {
        [self sharePhotosData];
    }
    
   
}
- (IBAction)clickHeadImageView:(UITapGestureRecognizer *)sender {
    
    WAAdvertiseViewController *vc = [[WAAdvertiseViewController alloc] initWithNibName:@"WAAdvertiseViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    
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
    
    if ([CoreArchive dicForKey:ADALBUM]) {
        NSString *photoUrl = [CoreArchive dicForKey:ADALBUM][AD_PHOTOURL];
         [self.headImageView sd_setImageWithURL:[NSURL URLWithString:photoUrl] placeholderImage:[UIImage imageNamed:@"banner"]];
    }
   
    
    if (![self.photosItem.nums integerValue]) {
        self.uploadPhotoNullView = [[[NSBundle mainBundle] loadNibNamed:@"UploadPhotoNullView" owner:self options:nil] lastObject];
        self.uploadPhotoNullView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.uploadPhotoNullView.delegate = self;
        [self.view addSubview:self.uploadPhotoNullView];
    }
    
    NSDictionary *userInfo = [CoreArchive dicForKey:USERINFO];
    if ([userInfo[@"userId"] isEqualToString:self.photosItem.author]) {
        self.editBtn.hidden = NO;
        self.uploadBtn.hidden = NO;
        self.headTitle.text = @"我";
        
        if (![userInfo[@"headUrl"] isKindOfClass:[NSNull class]]) {
            [self.headImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@!%@",userInfo[@"headUrl"],WEBP_HEADERF_APP]] placeholderImage:nil];
        }
        
    } else {
        
        self.editBtn.hidden = YES;
        self.uploadBtn.hidden = YES;
        self.lineLab.hidden = YES;
        NSMutableArray *qimiArr = [CoreArchive arrForKey:USER_QIMI_ARR];
        for (NSDictionary *dict in qimiArr) {
            
            NSLog(@"dict: %@", dict);
            NSString *qimiUser = dict[@"qinmiUser"];
            if ([dict[@"qinmiUser"] isKindOfClass:[NSNumber class]]) {
                qimiUser = [dict[@"qinmiUser"] stringValue];
            }
            if ([qimiUser isEqualToString:self.photosItem.author]) {
                self.headTitle.text = dict[@"qinmiName"];
                
                if (![dict[@"headUrl"] isKindOfClass:[NSNull class]]) {
                    [self.headImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@!%@",dict[@"headUrl"],WEBP_HEADERF_APP]] placeholderImage:nil];
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

    // The drop-down refresh
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //Call this Block When enter the refresh status automatically
        [self getPhotosList];
    }];
    
//    //实例化一个NSDateFormatter对象
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    //设定时间格式,这里可以设置成自己需要的格式
//    [dateFormatter setDateFormat:@"MM月dd日 HH:mm"];
//    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[self.photosItem.updateTime doubleValue]];
//    //用[NSDate date]可以获取系统当前时间
//    NSString *currentDateStr = [dateFormatter stringFromDate:confromTimesp];
    self.dateLab.text = self.photosItem.updateTime;
    
    [self.zanBtn setBackgroundImage:[UIImage imageNamed:@"zanLight"] forState:UIControlStateSelected];
    [self.zanBtn setBackgroundImage:[UIImage imageNamed:@"zanGray"] forState:UIControlStateNormal];
    
    [self sharePhotosData];
}

-(void)viewDidAppear:(BOOL)animated {
    
    if (-1 != self.delIndex) {
        [self delPhoto:self.delIndex];
        self.delIndex = -1;
    }
    
}

-(void)backAction {
    
    [MBProgressHUD hideHUD];
    
    if (self.isChange) {
        if (self.dataArr.count) {
            PhotoItem *item = self.dataArr[0];
            self.photosItem.coverUrl = item.photoUrl;
            self.photosItem.nums = [NSString stringWithFormat:@"%ld", self.dataArr.count];
        } else {
            self.photosItem.coverUrl = @"";
            self.photosItem.nums = @"0";
        }
        
        
        [self.delegate waNewPhotosViewControllerWithPhotosItem:self.photosItem andRefreshPhotoNum:self.dataArr.count];
    }
    
    
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

    if (!self.dataArr.count) {
        [self showAlertViewWithTitle:@"提示" message:@"您还没有上传照片，不能分享！" buttonTitle:@"确定" clickBtn:^{
            
        }];
        
        return;
    }
    
    if (self.hudShareView.hidden) {
        [UIView animateWithDuration:0.2 animations:^{
            //self.shareContant.constant = self.shareContant.constant == 0 ? -81 : 0;
            self.hudShareView.hidden = NO;
            self.shareView.frame = CGRectMake(0, SCREEN_HEIGHT-81-64, SCREEN_WIDTH, SCREEN_HEIGHT);
            
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.hudShareView.hidden = YES;
            self.shareView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
            
        }];
    }
    
 
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    self.cacheImags = [@{} mutableCopy];
    self.delIndex = -1;
    self.dataArr = [@[] mutableCopy];
    [self initView];
    
    //请求点赞情况
    [self  getZanData];
    
    [self photosListCachehandle];
    
}

-(void)photosListCachehandle {
    
    [MBProgressHUD showMessage:nil];
    if ([CoreArchive dicForKey:PHOTO_LIST_DICT]) {
        
        NSDictionary *dict = [CoreArchive dicForKey:PHOTO_LIST_DICT];
        
        if ([dict.allKeys containsObject:self.photosItem.albumId]) {
            NSArray *cacheDataArr = dict[self.photosItem.albumId];
            
            NSMutableArray *dataArr = [@[] mutableCopy];
            for (NSDictionary *dict  in cacheDataArr) {
                
                PhotoItem *item = [[PhotoItem alloc] init];
                item.createTime = dict[@"createTime"];
                item.photoHeight = dict[@"photoHeight"];
                item.photoId = dict[@"photoId"];
                item.photoSize = dict[@"photoSize"];
                item.photoUrl = dict[@"photoUrl"];
                item.photoWidth = dict[@"photoWidth"];
                
                [dataArr addObject:item];
            }
            
            [self.dataArr removeAllObjects];
            [self.dataArr addObjectsFromArray:dataArr];
            [self.collectionView reloadData];
            
            
           [self getPhotosList];
            
        } else {
            
            
            [self getPhotosList];
        }
        
    } else {
        
        [self getPhotosList];
    }
    
   

}

#pragma -mark WAUploadPhotoNullViewDelegate
-(void)waUploadPhotoNullViewWithClickUploadNewPhotos {
    
    [self clickUploadBtn:nil];
}

- (IBAction)clickUploadBtn:(UIButton *)sender {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if(status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted ){
        //无权限
        [self showAlertViewWithTitle:@"\n需开启 \"照片\" 权限 \n\n" message:nil cancelButtonTitle:@"取消" clickCancelBtn:^{
            
        } otherButtonTitles:@"去开启" clickOtherBtn:^{
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] openURL:url];
                });
            }
        }];
        
        return;
        
    } else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized) {
                
                // TODO:...
            }
        }];
        
        return;
    }
    
    ZLPhotoActionSheet *actionSheet = [[ZLPhotoActionSheet alloc] init];
    //设置照片最大预览数
    actionSheet.maxPreviewCount = 100;
    //
    actionSheet.allowTakePhotoInLibrary = NO;
//    //是否选择原图
    actionSheet.isSelectOriginalPhoto = YES;
    //设置照片最大选择数
    actionSheet.maxSelectCount = 25 - self.dataArr.count;
    actionSheet.sender = self;
    
    __weak __typeof__(self) weakSelf = self;
    [actionSheet setSelectImageBlock:^(NSArray<UIImage *> * _Nonnull images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
        //your codes
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [strongSelf uploadImage:images];
        
        CGFloat fixelW = CGImageGetWidth(images[0].CGImage);
        CGFloat fixelH = CGImageGetHeight(images[0].CGImage);
        NSLog(@"fixelW: %f %f", fixelH,fixelW);
        
    }];
    
    [actionSheet showPhotoLibrary];
    
}

-(void)photoListHandleWithPhotoLists:(NSArray *)photoLists andCompleteBlock:(void(^)(void))block {
    //上传相册
    NSDictionary *model = @{@"albumId":     self.photosItem.albumId,
                            @"photo_List": photoLists};
    
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P2103" andModel:model];
    __weak __typeof__(self) weakSelf = self;
    [CLNetworkingManager postNetworkRequestWithUrlString:ALBUM_URL parameters:params isCache:NO succeed:^(id data) {
       
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [strongSelf hideHud];
        
        NSString *code = data[@"code"];
        if ([code isEqualToString:@"0000"]) {
            
            //得到相册列表;
            [MBProgressHUD showMessage:nil];
            
            [strongSelf getPhotosList];
            
        } else {
            [MBProgressHUD showError:@"网络请求失败"];
        }
        
        block();
//        NSLog(@"信号发送04");
//        dispatch_semaphore_signal(semaphore);//发送信号
        
    } fail:^(NSError *error) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [MBProgressHUD showError:@"网络请求失败"];
        [strongSelf hideHud];
         block();
//        NSLog(@"信号发送05");
//        dispatch_semaphore_signal(semaphore);//发送信号
        
    }];

}
-(void)uploadImage:(NSArray *)images {
    
    if([AFNetworkReachabilityManager sharedManager].isReachable){ //----有网络

        [self hudShow:[NSString stringWithFormat:@"正在上传(0/%ld)...",images.count]];
        
        __weak __typeof__(self) weakSelf = self;
        dispatch_queue_t queue = dispatch_queue_create("com.wawj.www", DISPATCH_QUEUE_PRIORITY_DEFAULT);
        dispatch_async( queue, ^{
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            NSMutableArray *photoLists = [@[] mutableCopy];
            NSMutableArray *imageArr = [[NSMutableArray alloc] initWithArray:images];
            
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);//创建信号量
            for (int i = 0; i < imageArr.count+1; i++)
            {
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);//等待信号
                
                if (i == imageArr.count && photoLists.count > 0) {
                    //相册处理
                    [strongSelf photoListHandleWithPhotoLists:[NSArray arrayWithArray:photoLists] andCompleteBlock:^{
                        dispatch_semaphore_signal(semaphore);//发送信号
                    }];
                } else {

                    if (imageArr.count == 0) {
                        return ;
                    }
                    NSData *pngData = UIImagePNGRepresentation(imageArr[i]);
                    //图片命名
                    NSDate *currentDate = [NSDate date];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyyMMdd"];
                    NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
                    
                    NSString *uuid = [NSString stringWithFormat:@"%ld", (long)[currentDate timeIntervalSince1970]+i];
                    NSString *imgName=[NSString stringWithFormat:@"album/%@/%@%@.png", currentDateString,self.photosItem.albumId,uuid];

                    UpYunFormUploader *up = [[UpYunFormUploader alloc] init];
                    [up uploadWithBucketName:YUN_BUCKETNAMEPHOTO
                                    operator:YUN_OPERATOR
                                    password:YUN_PASSWORD
                                    fileData:pngData
                                    fileName:nil
                                     saveKey:imgName
                             otherParameters:nil
                                     success:^(NSHTTPURLResponse *response,NSDictionary *responseBody) {  //上传成功
                                         NSString *photoUrl = [NSString stringWithFormat:@"%@/%@",YUN_PHOTO,imgName];
                                         NSDictionary *photos = @{@"photo_url":photoUrl, @"photoSize":responseBody[@"file_size"], @"photoWidth":responseBody[@"image-width"], @"photoHeight":responseBody[@"image-height"]};
                                         [photoLists addObject:photos];
                                         
                                         [strongSelf.cacheImags setObject:pngData forKey:photoUrl];
                                         
                                         [strongSelf hudShow:[NSString stringWithFormat:@"正在上传(%ld/%ld)...",photoLists.count,imageArr.count]];
                                         
                                         dispatch_semaphore_signal(semaphore);//发送信号
                                         
                                     }failure:^(NSError *error,NSHTTPURLResponse *response,NSDictionary *responseBody) { //上传失败
                                         __strong __typeof__(weakSelf) strongSelf = weakSelf;
                                         
                                         [imageArr removeAllObjects];
                                         if (photoLists.count > 0) {
                                             //相册处理
                                             [strongSelf photoListHandleWithPhotoLists:[NSArray arrayWithArray:photoLists] andCompleteBlock:^{
                                                 NSLog(@"信号发送04: %@", [NSThread currentThread]);
                                                 dispatch_semaphore_signal(semaphore);//发送信号
                                                 dispatch_semaphore_signal(semaphore);//发送信号
                                                 
                                                 NSString *errorMsg = [NSString stringWithFormat:@"上传失败%ld张，成功%ld张",imageArr.count-photoLists.count,photoLists.count];
                                                 [strongSelf hideHudWithError:errorMsg];
                                                 
                                             }];
                                             
                                         } else {
                                             dispatch_semaphore_signal(semaphore);//发送信号
                                             dispatch_semaphore_signal(semaphore);//发送信号
                                             
                                             NSString *errorMsg = [NSString stringWithFormat:@"上传失败%ld张，成功%ld张",imageArr.count-photoLists.count,photoLists.count];
                                             [strongSelf hideHudWithError:errorMsg];
                                         }
                                         
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
    [CLNetworkingManager postNetworkRequestWithUrlString:ALBUM_URL parameters:params isCache:NO succeed:^(id data) {
        
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
        
            [MBProgressHUD hideHUD];
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
    
            [strongSelf showAlertViewWithTitle:@"提示" message:@"网络请求失败" buttonTitle:@"确定" clickBtn:^{
    
            }];
        
    }];

}


-(void)sharePhotosData {
    
    NSDictionary *model = @{@"albumId":     self.photosItem.albumId};
    
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P2105" andModel:model];
    __weak __typeof__(self) weakSelf = self;
    [CLNetworkingManager postNetworkRequestWithUrlString:ALBUM_URL parameters:params isCache:NO succeed:^(id data) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
//        [MBProgressHUD hideHUD];
        
        NSString *code = data[@"code"];
//        NSString *desc = data[@"desc"];
        if ([code isEqualToString:@"0000"]) {
            
            strongSelf.shareUrl = data[@"body"][@"url"];
            strongSelf.shareContent = data[@"body"][@"content"];
            strongSelf.shareTitle = data[@"body"][@"title"];
            
        } else {
            
//            [strongSelf showAlertViewWithTitle:@"提示" message:desc buttonTitle:@"确定" clickBtn:^{
//
//            }];
//            [MBProgressHUD showError:desc];
        
        }
        
    } fail:^(NSError *error) {
//        [MBProgressHUD hideHUD];
//        __strong __typeof__(weakSelf) strongSelf = weakSelf;
//
//        if ([strongSelf.shareUrl isEqualToString: @"request"]) {
//            [strongSelf showAlertViewWithTitle:@"提示" message:@"分享失败" buttonTitle:@"确定" clickBtn:^{
//
//            }];
//        }
//        [MBProgressHUD showError:error.localizedDescription];
        
    }];
    
}

#pragma -mark 相册列表
- (void)getPhotosList {


    if (![AFNetworkReachabilityManager sharedManager].isReachable) {
        
        if (self.collectionView.mj_header.isRefreshing) {
             [self.collectionView.mj_header endRefreshing];
        }
       
        [MBProgressHUD hideHUD];
        [MBProgressHUD showSuccess:@"网络未开启"];

        return;
    }
    
    
    NSDictionary *model = @{@"albumId":     self.photosItem.albumId,
                            @"lastestTime": @""};
    
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P2104" andModel:model];
    __weak __typeof__(self) weakSelf = self;
    [CLNetworkingManager postNetworkRequestWithUrlString:ALBUM_URL parameters:params isCache:NO succeed:^(id data) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [MBProgressHUD hideHUD];
        
        [strongSelf hideHud];
        
        if (strongSelf.collectionView.mj_header.isRefreshing) {
            [strongSelf.collectionView.mj_header endRefreshing];
        }
        
        NSString *code = data[@"code"];
        if ([code isEqualToString:@"0000"]) {
            
            if (![data[@"body"][@"photoList"] isKindOfClass:[NSNull class]]) {
                
                NSMutableArray *photosCacheArr = [@[] mutableCopy];
                NSMutableArray *dataArr = [@[] mutableCopy];
                for (NSDictionary *dict  in data[@"body"][@"photoList"]) {
                    
                    NSDictionary *transDict = [dict transforeNullValueToEmptyStringInSimpleDictionary];
                    
                    PhotoItem *item = [[PhotoItem alloc] init];
                    item.createTime = transDict[@"createTime"];
                    item.photoHeight = transDict[@"photoHeight"];
                    item.photoId = transDict[@"photoId"];
                    item.photoSize = transDict[@"photoSize"];
                    item.photoUrl = transDict[@"photoUrl"];
                    item.photoWidth = transDict[@"photoWidth"];
                    
                    [dataArr addObject:item];
                    [photosCacheArr addObject:transDict];
                    
                }
                
                if (photosCacheArr.count) {
                    
                    NSMutableDictionary *photoLists;
                    if ([CoreArchive dicForKey:PHOTO_LIST_DICT]) {
                        photoLists = [[NSMutableDictionary alloc] initWithDictionary:[CoreArchive dicForKey:PHOTO_LIST_DICT]];
                    } else {
                        photoLists = [[NSMutableDictionary alloc] init];
                    }
                    [photoLists setObject:photosCacheArr forKey:strongSelf.photosItem.albumId];
                    [CoreArchive setDic:photoLists key:PHOTO_LIST_DICT];
                    
                }
                
                
                if (!strongSelf.cacheImags.count) {
                    
                    if (strongSelf.uploadPhotoNullView) {
                        [strongSelf.uploadPhotoNullView removeFromSuperview];
                        strongSelf.uploadPhotoNullView = nil;
                    }
                    [strongSelf.dataArr removeAllObjects];
                    [strongSelf.dataArr addObjectsFromArray:dataArr];
                    [strongSelf.collectionView reloadData];
                } else {
                    
                    NSMutableArray *indexPaths = [@[] mutableCopy];
                    
                    for (NSInteger i = 0; i < strongSelf.cacheImags.count; i++) {
                        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    }
                    
                    if (strongSelf.uploadPhotoNullView) {
                        [strongSelf.uploadPhotoNullView removeFromSuperview];
                        strongSelf.uploadPhotoNullView = nil;
                    }
                    
                    [strongSelf.dataArr removeAllObjects];
                    [strongSelf.dataArr addObjectsFromArray:dataArr];
                    [UIView animateWithDuration:0.5 animations:^{
                        [strongSelf.collectionView insertItemsAtIndexPaths:indexPaths];
                    }];
                    
                }
                
                if (strongSelf.dataArr.count >= 25) {
                    strongSelf.uploadBtn.hidden = YES;
                    self.lineLab.hidden = YES;
                }
                
            }
            
            
        } else {
            
        }
        
    } fail:^(NSError *error) {
        
         [MBProgressHUD hideHUD];
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [strongSelf showAlertViewWithTitle:@"提示" message:@"网络请求失败" buttonTitle:@"确定" clickBtn:^{
            
        }];
        
        if (strongSelf.collectionView.mj_header.isRefreshing) {
            [strongSelf.collectionView.mj_header endRefreshing];
        }
        
    }];
    
}

-(void)waPhotosShowViewControllerWithDelPhotoIndex:(NSInteger)photoIndex {
    
    self.delIndex = photoIndex;
    
}

-(void)delPhoto:(NSInteger)photoIndex {
    
    self.isChange = YES;
    
    PhotoItem *item = self.dataArr[photoIndex];
    [self.dataArr removeObjectAtIndex:photoIndex];
    
    [UIView beginAnimations:nil context:nil]; // 开始动画
    [UIView setAnimationDuration:0.5]; // 动画时长
    
    [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:photoIndex inSection:0]]];
    
    [UIView commitAnimations]; // 提交动画
    
    
    NSDictionary *model = @{@"album_id":self.photosItem.albumId,
                            @"photoId":item.photoId};
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P2108" andModel:model];
    
    [CLNetworkingManager postNetworkRequestWithUrlString:ALBUM_URL parameters:params isCache:NO succeed:^(id data) {
        
        
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
        
        self.isChange = YES;
    } else {
        
        [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@!%@",item.photoUrl,WEBP_HEADER_FAMILY]] placeholderImage:[UIImage imageNamed:@"photoShowDefault"]];
    }
    
    return cell;
    
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}
//每一个分组的上左下右间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(1, 1, 1, 1);
}

//定义每一个cell的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((SCREEN_WIDTH-5)/3, (SCREEN_WIDTH-5)/3);
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
            
            strongSelf.hudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180, 120)];
            strongSelf.hudView.layer.masksToBounds = YES;
            strongSelf.hudView.layer.cornerRadius = 5.0f;
            strongSelf.hudView.backgroundColor = [UIColor darkGrayColor];
            strongSelf.hudView.alpha = 0.8;
            strongSelf.hudView.center = self.view.center;
            
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(60, 15, 30, 30)];
            indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
            [indicator startAnimating];
            
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, strongSelf.hudView.frame.size.width, 30)];
            lab.textAlignment = NSTextAlignmentCenter;
            lab.textColor = [UIColor whiteColor];
            lab.adjustsFontSizeToFitWidth = YES;
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

//-(void)clickHideHud {
//    if (self.hudView) {
//        [self.hudView removeFromSuperview];
//        self.hudView = nil;
//    }
//}

-(void)hideHudWithError:(NSString *)errorMessage {
    
   
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        __strong __typeof__(weakSelf) strongSelf = weakSelf;
//        strongSelf.hudView.frame = CGRectMake(0, 0, 200, 120);
//        strongSelf.hudView.center = self.view.center;
//
//        UILabel *lab = [strongSelf.hudView viewWithTag:100];
//        lab.frame = CGRectMake(0, 50, 200, 30);
//        lab.text = errorMessage;
//
//    });
    
    [self hudShow:errorMessage];
    
    
    [self performSelector:@selector(hideHud) withObject:nil afterDelay:3];
    
//     __weak __typeof__(self) weakSelf = self;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        __strong __typeof__(weakSelf) strongSelf = weakSelf;
//        if (strongSelf.hudView) {
//            [strongSelf.hudView removeFromSuperview];
//            strongSelf.hudView = nil;
//        }
//    });
    
    
    
}

-(void)getZanData {
    
    NSDictionary *model = @{@"album_id": self.photosItem.albumId};
    
    NSDictionary *params = [ParameterModel formatteNetParameterWithapiCode:@"P2107" andModel:model];
    
    __weak __typeof__(self) weakSelf = self;
    [CLNetworkingManager postNetworkRequestWithUrlString:ALBUM_URL parameters:params isCache:NO succeed:^(id data) {
        
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
