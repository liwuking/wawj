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
#import <AddressBook/AddressBook.h>

@interface WACommonlyPhoneViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray *dataArr;
@end

@implementation WACommonlyPhoneViewController

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)initView {
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"图层18"] style:UIBarButtonItemStyleDone target:self action:@selector(clickPhoneNumber)];
    [rightItem setTintColor:HEX_COLOR(0x666666)];
    [rightItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.title = @"常用联系人";
    
    
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


//cell的点击事件
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //cell被电击后移动的动画
    [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionTop];
    if (self.dataArr.count == indexPath.row) {
        [self clickPhoneNumber];
    } else {
        
        ContactItem *item = self.dataArr[indexPath.row];
        WAContactDetailViewController *vc = [[WAContactDetailViewController alloc] initWithNibName:@"WAContactDetailViewController" bundle:nil];
        vc.contactItem = item;
        [self.navigationController pushViewController:vc animated:YES];
        
//        [self showAlertViewWithTitle:@"提示" message:[NSString stringWithFormat:@"是否拨打%@的号码",item.name] cancelButtonTitle:@"取消" clickCancelBtn:^{
//
//        } otherButtonTitles:@"拨打" clickOtherBtn:^{
//            NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",item.phone];
//            //NSLog(@"str======%@",str);
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
//        }];
    }
    
}


-(void)clickPhoneNumber {
    
    __weak WACommonlyPhoneViewController *weakObject = self;
    [[LJContactManager sharedInstance] selectContactAtController:self complection:^(NSString *name, NSString *phone) {
        __strong WACommonlyPhoneViewController *strongObject = weakObject;
        
        ContactItem *item = [[ContactItem alloc] init];
        item.name = name;
        [item.phoneArr addObject:phone];
        
        [strongObject.dataArr addObject:item];
        
        [strongObject.collectionView reloadData];
        
        
        NSDictionary *contactDict = @{@"contactName":name,
                                      @"phoneArr":item.phoneArr
                                      };
        NSMutableArray *contactArrs = [[NSMutableArray alloc] initWithArray:[CoreArchive arrForKey:USER_CONTACT_ARR]];
        [contactArrs addObject:contactDict];
        [CoreArchive setArr:contactArrs key:USER_CONTACT_ARR];
        
    }];
    
}

- (void)requestAuthorizationAddressBook {
    // 判断是否授权
    ABAuthorizationStatus authorizationStatus = ABAddressBookGetAuthorizationStatus();
    if (authorizationStatus == kABAuthorizationStatusNotDetermined) {
        // 请求授权
        ABAddressBookRef addressBookRef = ABAddressBookCreate();
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) { // 授权成功
                NSLog(@"授权成功！");
            } else {  // 授权失败
                NSLog(@"授权失败！");
            }
        });
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.dataArr = [@[] mutableCopy];
    NSMutableArray *contactArr = [[NSMutableArray alloc] initWithArray:[CoreArchive arrForKey:USER_CONTACT_ARR]];
    for (NSDictionary *dict in contactArr) {
        ContactItem *item = [[ContactItem alloc] init];
        item.name = dict[@"name"];
        item.phoneArr = [[NSMutableArray alloc] initWithArray:dict[@"phoneArr"]];
        [self.dataArr addObject:item];
    }
    [self initView];
    
    [self.collectionView reloadData];
    
    //获取通讯录授权
     [self requestAuthorizationAddressBook];
    
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
        NSString *contactPath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"MyContact/%@",item.phoneArr[0]]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:contactPath]) {
            [cell.bgImg setImage:[UIImage imageWithContentsOfFile:contactPath]];
        }else {
            [cell.bgImg setImage:[UIImage imageNamed:@"oldFather"]];
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
    NSLog(@"width: %lf",width);
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
