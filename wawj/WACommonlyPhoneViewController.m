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
@interface WACommonlyPhoneViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray *dataArr;
@end

@implementation WACommonlyPhoneViewController

-(void)initView {
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
    [backItem setTintColor:HEX_COLOR(0x666666)];
    [backItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"图层18"] style:UIBarButtonItemStyleDone target:self action:@selector(clickPhoneNumber)];
    [rightItem setTintColor:HEX_COLOR(0x666666)];
    [rightItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.title = @"常用电话";
    
    
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

    //这种是自定义cell不带xib的注册
    //   [_collectionView registerClass:[CollectionViewCell1 class] forCellWithReuseIdentifier:@"myheheIdentifier"];
    //这种是原生cell的注册
    //    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
}

-(void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)clickPhoneNumber {
    
    __weak WACommonlyPhoneViewController *weakObject = self;
    [[LJContactManager sharedInstance] selectContactAtController:self complection:^(NSString *name, NSString *phone) {
        __strong WACommonlyPhoneViewController *strongObject = weakObject;
        
        ContactItem *item = [[ContactItem alloc] init];
        item.name = name;
        item.phone = phone;
        
        [strongObject.dataArr addObject:item];
        
        [strongObject.collectionView reloadData];
        
    }];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.dataArr = [@[] mutableCopy];
    [self initView];
    
}

//一共有多少个组
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

//每一组有多少个cell
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArr.count+1;
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
        [cell.bgImg setImage:[UIImage imageNamed:@"oldFather"]];
        return cell;
    }
    
}

//每一个分组的上左下右间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

//定义每一个cell的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(115, 115);
}

//cell的点击事件
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //cell被电击后移动的动画
    [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionTop];
    if (self.dataArr.count == indexPath.row) {
        [self clickPhoneNumber];
    } else {
        
         ContactItem *item = self.dataArr[indexPath.row];
        
        [self showAlertViewWithTitle:@"提示" message:[NSString stringWithFormat:@"是否拨打%@的号码",item.name] cancelButtonTitle:@"取消" clickCancelBtn:^{
            
        } otherButtonTitles:@"拨打" clickOtherBtn:^{
            NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",item.phone];
            //NSLog(@"str======%@",str);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }];
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
