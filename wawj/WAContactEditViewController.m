//
//  WAContactEditViewController.m
//  wawj
//
//  Created by ruiyou on 2017/11/1.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAContactEditViewController.h"
#import "EditAddTableViewCell.h"
#import "EditNameTableViewCell.h"
#import "EditPhoneTableViewCell.h"
#import "EditHeadImageTableViewCell.h"
#import "WACommonlyPhoneViewController.h"
#import <Contacts/Contacts.h>
@interface WAContactEditViewController ()<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *delBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewConstant;
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property(nonatomic,assign)BOOL isChangeHeadImage;
@end

@implementation WAContactEditViewController

-(void)clickCancel {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSArray *)queryContactWithName:(NSString *)name{
    
    CNContactStore *store = [[CNContactStore alloc] init];
    //检索条件
    NSPredicate *predicate = [CNContact predicateForContactsMatchingName:name];
    
    //过滤的条件，也可以过滤时候格式化
    NSArray *keysToFetch = @[CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey,CNContactImageDataKey];
    
    NSArray *contact = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keysToFetch error:nil];
    return contact;
}

-(void)updateContactsName:(NSString *)originName andNewName: (NSString *)newName imageName:(NSString *)imageName phoneNumber:(NSArray <NSString *>*)phoneNumbers {
    
    if (![self queryContactWithName:originName].count) {
        
        [self addContactsName:newName imageName:imageName phoneNumber:phoneNumbers];
        
    } else {
        CNMutableContact * contact = [[[self queryContactWithName:originName] objectAtIndex:0] mutableCopy];
        //名字
        contact.givenName = newName;
        contact.familyName = @"";
        NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)[0];
        NSString *imageContactPath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"MyContact/%@",imageName]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:imageContactPath]) {
            //头像
            contact.imageData = [NSData dataWithContentsOfFile:imageContactPath];
        }
        
        NSMutableArray <CNLabeledValue<CNPhoneNumber*>*>  *nums = [@[] mutableCopy];
        for (NSString *phone in phoneNumbers) {
            CNLabeledValue *value = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberiPhone value:[CNPhoneNumber phoneNumberWithStringValue:phone]];
            [nums addObject:value];
            
        }
        //电话号码
        contact.phoneNumbers = [NSArray arrayWithArray:nums];
        //保存请求
        CNSaveRequest * saveRequest = [[CNSaveRequest alloc] init];
        [saveRequest updateContact:contact];
        //上下文
        CNContactStore * store = [[CNContactStore alloc] init];
        NSError *error;
        [store executeSaveRequest:saveRequest error:&error];
        
        if (error) {
            NSLog(@"error.localizedDescription: %@",error.localizedDescription);
        }
    }
    
    
}

-(void)addContactsName:(NSString *)givenName imageName:(NSString *)imageName phoneNumber:(NSArray <NSString *>*)phoneNumbers {
    
    //生成联系人
    CNMutableContact * contact = [[CNMutableContact alloc] init];
    
    //名字
    contact.givenName = givenName;
    contact.familyName = @"";
    //头像
//    contact.imageData = UIImagePNGRepresentation(self.headImageView.image);
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)[0];
    NSString *imageContactPath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"MyContact/%@",imageName]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageContactPath]) {
        contact.imageData = [NSData dataWithContentsOfFile:imageContactPath];
    }

    //电话号码
    NSMutableArray <CNLabeledValue<CNPhoneNumber*>*>  *nums = [@[] mutableCopy];
    for (NSString *phone in phoneNumbers) {
        CNLabeledValue *value = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberiPhone value:[CNPhoneNumber phoneNumberWithStringValue:phone]];
        [nums addObject:value];
        
    }
    contact.phoneNumbers = [NSArray arrayWithArray:nums];
    
    //保存请求
    CNSaveRequest * saveRequest = [[CNSaveRequest alloc] init];
    [saveRequest addContact:contact toContainerWithIdentifier:nil];
    //上下文
    CNContactStore * store = [[CNContactStore alloc] init];
    [store executeSaveRequest:saveRequest error:nil];
    

}

-(void)delContact {
    
    NSMutableArray *contactArr = [[NSMutableArray alloc] initWithArray:[CoreArchive arrForKey:USER_CONTACT_ARR]];
    for (NSInteger i = 0; i < contactArr.count; i++) {
        NSDictionary *dict = contactArr[i];
        if ([dict[@"contactName"] isEqualToString:self.contactItem.name]) {
            [contactArr removeObjectAtIndex:i];
            break;
        }
    }
    [CoreArchive setArr:contactArr key:USER_CONTACT_ARR];
    
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)[0];
    NSString *oldContactPath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"MyContact/%@",self.contactItem.imageName]];
    [[NSFileManager defaultManager] removeItemAtPath:oldContactPath error:nil];
    
    [MBProgressHUD showMessage:nil];
    //创建一个串行队列
    dispatch_queue_t queue = dispatch_queue_create("xxxx", DISPATCH_QUEUE_SERIAL);
    //使用异步函数封装三个任务
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(queue, ^{
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        [strongSelf delContactWithName:strongSelf.contactItem.name];
    });

    dispatch_async(queue, ^{
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
            for (UIViewController *temp in strongSelf.navigationController.viewControllers) {
                if ([temp isKindOfClass:[WACommonlyPhoneViewController class]]) {
            
                    strongSelf.waContactDelChange(strongSelf.contactItem);
                    [strongSelf.navigationController popToViewController:temp animated:YES];
                    
                }
            }
        });
        
    });
}

-(void)clickDel {
    
    if (self.waContactEditType == WAContactEditEdit) {
        
        __weak __typeof__(self) weakSelf = self;
        [self showAlertViewWithTitle:@"确定删除" message:@"通讯录中联系人会同步删除" buttonTitle:@"确定" clickBtn:^{
           __strong __typeof__(weakSelf) strongSelf = weakSelf;
            [strongSelf delContact];
        }];

    } else {
        [self clickSave:self.delBtn];
    }

    
}

- (BOOL) deptNumInputShouldNumber:(NSString *)str
{
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}

-(void)delContactWithName:(NSString *)name {
    
    if ([[self queryContactWithName:name] count]) {
        CNMutableContact * contact = [[[self queryContactWithName:name] objectAtIndex:0] mutableCopy];
        //保存请求
        CNSaveRequest * saveRequest = [[CNSaveRequest alloc] init];
        [saveRequest deleteContact:contact];
        //上下文
        CNContactStore * store = [[CNContactStore alloc] init];
        NSError *error;
        [store executeSaveRequest:saveRequest error:&error];
        
        if (error) {
            NSLog(@"error.localizedDescription: %@",error.localizedDescription);
        }
    }
    
   
}

- (IBAction)clickSave:(UIButton *)sender {
    
    
    [self.view endEditing:YES];
    
    if (self.waContactEditType == WAContactEditAdd && !self.isChangeHeadImage) {
        [self showAlertViewWithTitle:@"您还没有添加头像" message:nil buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }
    
    EditNameTableViewCell *cellName = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (!cellName.textField.text.length) {
        [self showAlertViewWithTitle:@"请输入姓名" message:nil buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }
    
    NSMutableArray *contactArr = [[NSMutableArray alloc] initWithArray:[CoreArchive arrForKey:USER_CONTACT_ARR]];
    NSString *currentName = cellName.textField.text;
    if (![self.contactItem.name isEqualToString:currentName]) {
        for (NSDictionary *dict in contactArr) {
            
            if ([dict[@"contactName"] isEqualToString:currentName]) {
                [self showAlertViewWithTitle:@"已存在相同姓名" message:nil buttonTitle:@"确定" clickBtn:^{
                    
                }];
                return;
            }
            
        }
    }
    
    
    
    BOOL ischange = [cellName.textField.text isEqualToString:self.contactItem.name];
    EditPhoneTableViewCell *cellPhone1 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    if (!cellPhone1.textField.text.length) {
        [self showAlertViewWithTitle:@"请输入电话号码1" message:nil buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }
    
    if (![self deptNumInputShouldNumber:cellPhone1.textField.text]) {
        [self showAlertViewWithTitle:@"电话号码只允许输入数字" message:nil buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }
    
    if (![self valiMobile:cellPhone1.textField.text]) {
        [self showAlertViewWithTitle:@"请输入正确的电话号码1" message:nil buttonTitle:@"确定" clickBtn:^{
            
        }];
        return;
    }
    ischange = [cellPhone1.textField.text isEqualToString:self.contactItem.phoneArr[0]] && ischange;
    self.contactItem.phoneArr[0] = cellPhone1.textField.text;
    
    
    if (self.contactItem.phoneArr.count == 2) {
        EditPhoneTableViewCell *cellPhone2 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        
        if (!cellPhone2.textField.text.length) {
            [self showAlertViewWithTitle:@"请输入电话号码2" message:nil buttonTitle:@"确定" clickBtn:^{
                
            }];
            return;
        }
        if (![self deptNumInputShouldNumber:cellPhone2.textField.text]) {
            [self showAlertViewWithTitle:@"电话号码只允许输入数字" message:nil buttonTitle:@"确定" clickBtn:^{
                
            }];
            return;
        }
        if (![self valiMobile:cellPhone2.textField.text]) {
            [self showAlertViewWithTitle:@"请输入正确的电话号码2" message:nil buttonTitle:@"确定" clickBtn:^{
                
            }];
            return;
        }
        
        ischange = [cellPhone2.textField.text isEqualToString:self.contactItem.phoneArr[0]] && ischange;
        self.contactItem.phoneArr[1] = cellPhone2.textField.text;
        
    }

    if (self.isChangeHeadImage) {
        
        NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)[0];
        NSString *oldContactPath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"MyContact/%@",self.contactItem.imageName]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:oldContactPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:oldContactPath error:nil];
        }
        
        
        self.contactItem.imageName = [NSString stringWithFormat:@"%ld",(NSInteger)[[NSDate date] timeIntervalSince1970]];
        NSString *contactPath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"MyContact/%@",self.contactItem.imageName]];
        [[NSFileManager defaultManager] createFileAtPath:contactPath contents:UIImageJPEGRepresentation(self.headImageView.image,0.5) attributes:nil];
    }
    ischange = ischange && !self.isChangeHeadImage;
    
    NSString *originContactName =  self.contactItem.name;
    self.contactItem.name = cellName.textField.text;
    if (!ischange && WAContactEditEdit == self.waContactEditType) {
        
        self.waContactEditChange(self.contactItem);
        
        //创建一个串行队列
        dispatch_queue_t queue = dispatch_queue_create("xxxx", DISPATCH_QUEUE_SERIAL);
        //使用异步函数封装三个任务
        __weak __typeof__(self) weakSelf = self;
        [MBProgressHUD showMessage:nil];
        dispatch_async(queue, ^{
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            
            [strongSelf updateContactsName:originContactName andNewName:strongSelf.contactItem.name imageName:strongSelf.contactItem.imageName phoneNumber:strongSelf.contactItem.phoneArr];
            
        });
        
        dispatch_async(queue, ^{
            
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUD];
                [strongSelf.navigationController popViewControllerAnimated:YES];
            });
        });
        
    }else if (ischange && WAContactEditEdit == self.waContactEditType) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (WAContactEditAdd == self.waContactEditType) {
        
        if ([self queryContactWithName:cellName.textField.text].count) {
            [self showAlertViewWithTitle:@"手机通讯录中已存在相同姓名,请直接添加" message:nil buttonTitle:@"确定" clickBtn:^{
                
            }];
            return;
        }
        
        self.waContactEditAddChange(self.contactItem);
        
        //创建一个串行队列
        dispatch_queue_t queue = dispatch_queue_create("xxxx", DISPATCH_QUEUE_SERIAL);
        //使用异步函数封装三个任务
        __weak __typeof__(self) weakSelf = self;
        [MBProgressHUD showMessage:nil];
        dispatch_async(queue, ^{
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            [strongSelf addContactsName:strongSelf.contactItem.name imageName:strongSelf.contactItem.imageName phoneNumber:strongSelf.contactItem.phoneArr];
        });
        
        dispatch_async(queue, ^{
            
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUD];
                [strongSelf.navigationController popViewControllerAnimated:YES];
                
            });
            
        });
        
    }
    
    
}

//判断手机号码格式是否正确
- (BOOL)valiMobile:(NSString *)mobile
{
    if ([mobile hasPrefix:@"0"] && mobile.length <= 12) {
        return YES;
    }else if( mobile.length <= 11) {
        return YES;
    }
    
    return NO;
}

-(void)initView {
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    if (self.waContactEditType == WAContactEditAdd) {
       
        self.title = @"添加联系人";
        
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(clickDel)];
        [rightItem setTintColor:HEX_COLOR(0x666666)];
        [rightItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
        self.navigationItem.rightBarButtonItem = rightItem;
        
    } else {
        
        self.title = @"编辑联系人";
        
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStyleDone target:self action:@selector(clickDel)];
        [rightItem setTintColor:HEX_COLOR(0x666666)];
        [rightItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(clickCancel)];
    [leftItem setTintColor:HEX_COLOR(0x666666)];
    [leftItem setImageInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.headView.layer.borderWidth = 1;
    self.headView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)[0];
    NSString *contactPath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"MyContact/%@",self.contactItem.imageName]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:contactPath]) {
        [self.headImageView setImage:[UIImage imageWithContentsOfFile:contactPath]];
    }else {
        [self.headImageView setImage:[UIImage imageNamed:@"photoShowDefault"]];
    }
    
    
    self.tableView.layer.borderWidth = 1;
    self.tableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
 
    
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (self.waContactEditType == WAContactEditAdd) {
        self.contactItem = [[ContactItem alloc] init];
        [self.contactItem.phoneArr addObject:@""];
    }
    
    [self initView];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
- (IBAction)clickChangeHead:(UITapGestureRecognizer *)sender {

    //初始化图片选择控制器
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.allowsEditing = YES; //设置拍照时的下方的工具栏是否显示，如果需要自定义拍摄界面，则可把该工具栏隐藏
    imagePicker.delegate = self;
   
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击取消");
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"选择现有照片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //判断摄像头是否可用
        BOOL isCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
        if (!isCamera) {
            NSLog(@"没有摄像头");
            return;
        }
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }]];
    
    // 由于它是一个控制器 直接modal出来就好了
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    
}

//得到图片或者视频后, 调用该代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *images = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.headImageView.image = images;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    self.isChangeHeadImage = YES;
}

//当用户取消相册时, 调用该方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (2 == indexPath.row) {
        
        if (self.contactItem.phoneArr.count == 1) {
            [self.contactItem.phoneArr addObject:@""];
        }
        
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(0 == indexPath.row){
        EditNameTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"EditNameTableViewCell" owner:self options:nil] lastObject];
        cell.textField.delegate = self;
        if (self.contactItem.name.length) {
            cell.textField.text = self.contactItem.name;
        }
         return cell;
    }
    
    if(1 == indexPath.row){
        EditPhoneTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"EditPhoneTableViewCell" owner:self options:nil] lastObject];
        cell.textField.delegate = self;
        cell.textField.placeholder = @"电话号码1";
        if (self.waContactEditType == WAContactEditEdit && self.contactItem.phoneArr[0].length) {
            cell.textField.text = self.contactItem.phoneArr[0];
        }
        
        return cell;
    }
    
    if(2 == self.contactItem.phoneArr.count && 2 == indexPath.row){
       EditPhoneTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"EditPhoneTableViewCell" owner:self options:nil] lastObject];
        cell.textField.delegate = self;
        cell.textField.placeholder = @"电话号码2";
        if (self.waContactEditType == WAContactEditEdit && self.contactItem.phoneArr[1].length) {
            cell.textField.text = self.contactItem.phoneArr[1];
        }
        return cell;
    } else {
        EditAddTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"EditAddTableViewCell" owner:self options:nil] lastObject];
         return cell;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  3;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];

    return YES;
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
