//
//  WACommonlyPhoneViewController.m
//  wawj
//
//  Created by ruiyou on 2017/8/2.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WACommonlyPhoneViewController.h"
#import "WACommonCell.h"
#import "WACommonAddCell.h"
#import "LJContactManager.h"
#import "ContactItem.h"
#import "WAContactDetailViewController.h"
#import <Contacts/Contacts.h>
#import "WAContactEditViewController.h"
#import <objc/runtime.h>
#import "AddContactView.h"

@interface WACommonlyPhoneViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray *dataArr;
@property(nonatomic,strong)AddContactView *addContactView;
@end

@implementation WACommonlyPhoneViewController

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)initView {
    
    self.title = @"常用电话";
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"图层18"] style:UIBarButtonItemStyleDone target:self action:@selector(clickPhoneNumber)];
//    [rightItem setTintColor:HEX_COLOR(0x666666)];
//    [rightItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
//    self.navigationItem.rightBarButtonItem = rightItem;
    

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
    UINib *cellNib=[UINib nibWithNibName:@"WACommonCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:@"WACommonCell"];
    UINib *cellAddNib=[UINib nibWithNibName:@"WACommonAddCell" bundle:nil];
    [_collectionView registerNib:cellAddNib forCellWithReuseIdentifier:@"WACommonAddCell"];

    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.addContactView) {
        self.addContactView = [[[NSBundle mainBundle] loadNibNamed:@"AddContactView" owner:nil options:nil] lastObject];
        self.addContactView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.addContactView.hidden = YES;
        self.addContactView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [self.view addSubview:self.addContactView];
        
        __weak __typeof__(self) weakSelf = self;
        self.addContactView.addContactViewAddOldContact = ^{
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            [strongSelf clickPhoneNumber];
            strongSelf.addContactView.hidden = YES;
        };
        
        self.addContactView.addContactViewAddNewContact = ^{
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            
            [strongSelf addUserContact];
            strongSelf.addContactView.hidden = YES;
        };
        
        self.addContactView.addContactViewAddHidden = ^{
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            strongSelf.addContactView.hidden = YES;
        };
        
    }
}

-(void)addUserContact {
    
    WAContactEditViewController *waContactEditViewController = [[WAContactEditViewController alloc] initWithNibName:@"WAContactEditViewController" bundle:nil];
    waContactEditViewController.waContactEditType = WAContactEditAdd;
    [self.navigationController pushViewController:waContactEditViewController animated:YES];
    
    __weak __typeof__(self) weakSelf = self;
    waContactEditViewController.waContactEditAddChange = ^(ContactItem *contactItem) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [strongSelf.dataArr addObject:contactItem];
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:strongSelf.dataArr.count-1 inSection:0]]];
        
        NSMutableArray *contactArr = [[NSMutableArray alloc] initWithArray:[CoreArchive arrForKey:USER_CONTACT_ARR]];
        NSDictionary *contactDict = @{@"contactName":contactItem.name,
                                      @"phoneArr":contactItem.phoneArr,
                                      @"imageName":contactItem.imageName
                                      };
        [contactArr addObject:contactDict];
        [CoreArchive setArr:contactArr key:USER_CONTACT_ARR];
    };
    
}

//kvc 获取所有key值
- (NSArray *)getAllIvar:(id)object
{
    NSMutableArray *array = [NSMutableArray array];
    
    unsigned int count;
    Ivar *ivars = class_copyIvarList([object class], &count);
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivars[i];
        const char *keyChar = ivar_getName(ivar);
        NSString *keyStr = [NSString stringWithCString:keyChar encoding:NSUTF8StringEncoding];
        @try {
            id valueStr = [object valueForKey:keyStr];
            NSDictionary *dic = nil;
            if (valueStr) {
                dic = @{keyStr : valueStr};
            } else {
                dic = @{keyStr : @"值为nil"};
            }
            [array addObject:dic];
        }
        @catch (NSException *exception) {}
    }
    return [array copy];
}

//获得所有属性
- (NSArray *)getAllProperty:(id)object
{
    NSMutableArray *array = [NSMutableArray array];
    
    unsigned int count;
    objc_property_t *propertys = class_copyPropertyList([object class], &count);
    for (int i = 0; i < count; i++) {
        objc_property_t property = propertys[i];
        const char *nameChar = property_getName(property);
        NSString *nameStr = [NSString stringWithCString:nameChar encoding:NSUTF8StringEncoding];
        [array addObject:nameStr];
    }
    return [array copy];
}

//cell的点击事件
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //cell被电击后移动的动画
    [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionTop];
    if (self.dataArr.count == indexPath.row) {
        
       
       
        self.addContactView.hidden = NO;
        
        
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//            NSLog(@"点击取消");
//        }]];
//
//
//       UIAlertAction *phoneAc = [UIAlertAction actionWithTitle:@"从电话本中添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//
//       }];
//        [alertController addAction:phoneAc];
//
//        [alertController addAction:[UIAlertAction actionWithTitle:@"添加新联系人" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            __strong __typeof__(weakSelf) strongSelf = weakSelf;
//
//            [strongSelf addUserContact];
//
//        }]];
//
////        UILabel *view = [UILabel appearanceWhenContainedInInstancesOfClasses:@[alertController.class]];
////        view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 400);
////        view.backgroundColor = [UIColor redColor];
////
////        NSLog(@"alertController.actions[0]: %@",[self getAllProperty:alertController.actions[0]]);
////        NSLog(@"[self getAllProperty:alertController]: %@",[self getAllProperty:alertController]);
//
//        // 由于它是一个控制器 直接modal出来就好了
//        [self presentViewController:alertController animated:YES completion:nil];

    } else {
        
        ContactItem *item = self.dataArr[indexPath.row];
        [item.phoneArr removeObject:@""];
        WAContactDetailViewController *waContactDetailViewController = [[WAContactDetailViewController alloc] initWithNibName:@"WAContactDetailViewController" bundle:nil];
        waContactDetailViewController.contactItem = item;
        [self.navigationController pushViewController:waContactDetailViewController animated:YES];
        
        __weak __typeof__(self) weakSelf = self;
        waContactDetailViewController.waContactDetailChange = ^(ContactItem *contactItem) {
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            
            [strongSelf.dataArr replaceObjectAtIndex:indexPath.row withObject:contactItem];
            [strongSelf.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            
            NSMutableArray *userArr = [@[] mutableCopy];
            for (ContactItem *item in strongSelf.dataArr) {
                NSDictionary *contactDict = @{@"contactName":item.name,
                                              @"phoneArr":item.phoneArr,
                                              @"imageName":item.imageName
                                              };
                [userArr addObject:contactDict];
            }
            [CoreArchive setArr:userArr key:USER_CONTACT_ARR];

        };
        
        waContactDetailViewController.waContactDetailDel = ^(ContactItem *contactItem) {
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            [strongSelf.dataArr removeObjectAtIndex:indexPath.row];
            [strongSelf.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        };
        
        
    }
    
}

- (BOOL)requestAuthorizationAddressBook {
    // 判断是否授权
    CNAuthorizationStatus authorizationStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (authorizationStatus == CNAuthorizationStatusNotDetermined) {
        // 请求授权
        CNContactStore * store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) { // 授权成功
                NSLog(@"授权成功！");
               
            } else {  // 授权失败
                NSLog(@"授权失败！");
                
            }
            
        }];
        return NO;
    } else if(authorizationStatus == CNAuthorizationStatusDenied || authorizationStatus == CNAuthorizationStatusRestricted){
        //设置-隐私-通讯录
        
        [self showAlertViewWithTitle:@"\n需开启 \"通讯录\" 权限 \n\n" message:nil cancelButtonTitle:@"取消" clickCancelBtn:^{
            
        } otherButtonTitles:@"去开启" clickOtherBtn:^{
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] openURL:url];
                });
            }
        }];
        return NO;
        
    }
    
    return YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.dataArr = [@[] mutableCopy];
    NSMutableArray *contactArr = [[NSMutableArray alloc] initWithArray:[CoreArchive arrForKey:USER_CONTACT_ARR]];
    for (NSDictionary *dict in contactArr) {
        ContactItem *item = [[ContactItem alloc] init];
        item.imageName = dict[@"imageName"];
        item.name = dict[@"contactName"];
        item.phoneArr = [[NSMutableArray alloc] initWithArray:dict[@"phoneArr"]];
        [self.dataArr addObject:item];
    }
    [self initView];
    
    [self.collectionView reloadData];
    
    //获取通讯录授权
     [self requestAuthorizationAddressBook];
    
}

-(void)clickPhoneNumber {
    
    if (![self requestAuthorizationAddressBook]) {
        return;
    }
    
    __weak WACommonlyPhoneViewController *weakObject = self;
    [[LJContactManager sharedInstance] selectContactAtController:self complection:^(NSString *name, NSString *phone,NSData *imageData) {
        __strong WACommonlyPhoneViewController *strongObject = weakObject;
        
        for (ContactItem *item in self.dataArr) {
            if ([item.name isEqualToString:name]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [strongObject showAlertViewWithTitle:@"已存在相同姓名" message:nil buttonTitle:@"确定" clickBtn:^{
                    }];
                });
                return;
                break;
            }
        }
        
        
        ContactItem *item = [[ContactItem alloc] init];
        item.name = name;
        NSString *imageName = [NSString stringWithFormat:@"%ld", (NSInteger)[[NSDate date] timeIntervalSince1970]];
        item.imageName = imageName;
        phone = [NSString stringWithFormat:@"%@", phone];
        phone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
        phone = [[phone componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""];
        [item.phoneArr addObject:phone];
        [strongObject.dataArr addObject:item];

        if (imageData) {
            NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)[0];
            NSString *contactPath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"MyContact/%@",imageName]];
            
            [[NSFileManager defaultManager] createFileAtPath:contactPath contents:imageData attributes:nil];
        }
        
        NSDictionary *contactDict = @{@"contactName":name,
                                      @"phoneArr":item.phoneArr,
                                      @"imageName":imageName
                                      };
        NSMutableArray *contactArrs = [[NSMutableArray alloc] initWithArray:[CoreArchive arrForKey:USER_CONTACT_ARR]];
        [contactArrs addObject:contactDict];
        [CoreArchive setArr:contactArrs key:USER_CONTACT_ARR];
        
        
        [strongObject.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:strongObject.dataArr.count-1 inSection:0]]];
        
    }];
    
}

//每一个cell是什么
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.dataArr.count == indexPath.row) {
        WACommonAddCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"WACommonAddCell" forIndexPath:indexPath];
        return cell;
    } else {
        WACommonCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"WACommonCell" forIndexPath:indexPath];
        ContactItem *item = self.dataArr[indexPath.row];
        cell.titleLab.text= item.name;
        
        NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)[0];
        NSString *contactPath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"MyContact/%@",item.imageName]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:contactPath]) {
            [cell.bgImg setImage:[UIImage imageWithContentsOfFile:contactPath]];
        }else {
            [cell.bgImg setImage:[UIImage imageNamed:@"photoShowDefault"]];
        }
        
        
        return cell;
    }
    
}

//一共有多少个组
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

//每一组有多少个cell
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArr.count+1;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
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
//    CGFloat height = (width/140) * 170;
//    NSLog(@"width: %lf",width);
    return CGSizeMake(width, width);
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
