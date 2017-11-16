//
//  TimePickerView.m
//  wawj
//
//  Created by ruiyou on 2017/10/23.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "TimePickerView.h"

#define  ROWNUM_HOUR      38400
#define  ROWNUM_MINUTE    96000

@interface TimePickerView()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (nonatomic,strong)NSArray<NSArray *> *dataArr;
@property (nonatomic,assign)NSInteger firstIndex;
@property (nonatomic,assign)NSInteger secondIndex;
@property (nonatomic,strong,readwrite)NSString *selectedTime;

@end
@implementation TimePickerView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    NSMutableArray *arrOne = [@[] mutableCopy];
    NSMutableArray *arrTwo = [@[] mutableCopy];
    
    for (NSInteger i = 0; i < 24; i++) {
        if (i < 10) {
            [arrOne addObject:[NSString stringWithFormat:@"0%ld", i]];
        } else {
            [arrOne addObject:[NSString stringWithFormat:@"%ld", i]];
        }
    }
    
    for (NSInteger i = 0; i < 60; i++) {
        if (i < 10) {
            [arrTwo addObject:[NSString stringWithFormat:@"0%ld", i]];
        } else {
            [arrTwo addObject:[NSString stringWithFormat:@"%ld", i]];
        }
    }
    
    self.dataArr = @[arrOne,arrTwo];
    
    [self.pickerView.subviews objectAtIndex:1].layer.borderWidth = 0.5f;
    [self.pickerView.subviews objectAtIndex:2].layer.borderWidth = 0.5f;
    [self.pickerView.subviews objectAtIndex:1].layer.borderColor = HEX_COLOR(0x219CE0).CGColor;
    [self.pickerView.subviews objectAtIndex:2].layer.borderColor = HEX_COLOR(0x219CE0).CGColor;
    
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [self.pickerView reloadAllComponents];
    
    __weak __typeof__(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        strongSelf.firstIndex = [[self.currentTime componentsSeparatedByString:@":"][0] integerValue]+ROWNUM_HOUR/2;
        strongSelf.secondIndex = [[self.currentTime componentsSeparatedByString:@":"][1] integerValue]+ROWNUM_MINUTE/2;
    
        [strongSelf.pickerView selectRow:self.firstIndex inComponent:0 animated:NO];
        [strongSelf.pickerView selectRow:self.secondIndex inComponent:1 animated:NO];
        
        [strongSelf pickerView:self.pickerView didSelectRow:self.firstIndex inComponent:0];
        [strongSelf pickerView:self.pickerView didSelectRow:self.secondIndex inComponent:1];
    } completion:^(BOOL finished) {
        
    }];
    
    
}

-(void)setIsEnble:(BOOL)isEnble {
    _isEnble = isEnble;
     self.pickerView.userInteractionEnabled = self.isEnble;
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    
    /*重新定义row 的UILabel*/
    UILabel *pickerLabel = (UILabel*)view;
    
    if (!pickerLabel){
        
        pickerLabel = [[UILabel alloc] init];
        [pickerLabel setTextColor:[UIColor blackColor]];
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont systemFontOfSize:30.0f]];
        
    }
    
    if(component == 0){
        
        if(row == self.firstIndex){
//            NSLog(@"_firstIndex: %ld",self.firstIndex);
            /*选中后的row的字体颜色*/
            /*重写- (nullable NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component NS_AVAILABLE_IOS(6_0) __TVOS_PROHIBITED; 方法加载 attributedText*/
            
            pickerLabel.attributedText
            = [self pickerView:pickerView attributedTitleForRow:self.firstIndex forComponent:component];
            
        }else{
            
            pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
        }
        
    }else if (component == 1){
        
        if(row == self.secondIndex){
//            NSLog(@"secondIndex: %ld",self.secondIndex);
            pickerLabel.attributedText
            = [self pickerView:pickerView attributedTitleForRow:self.secondIndex forComponent:component];
        }else{
            
            pickerLabel.text = [NSString stringWithFormat:@"%@",[self pickerView:pickerView titleForRow:row forComponent:component]];
        }
        
    }
    return pickerLabel;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    NSString *titleString;
    if(0 == component){
        NSInteger index = row%24;
        titleString = self.dataArr[component][index];
    } else {
        NSInteger index = row%60;
        titleString = self.dataArr[component][index];
    }
    
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:titleString];
    NSRange range = [titleString rangeOfString:titleString];
    [attributedString addAttribute:NSForegroundColorAttributeName value:HEX_COLOR(0x219CE0) range:range];
    
    return attributedString;
}

//UIPickerViewDataSource中定义的方法，该方法的返回值决定该控件包含的列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    return self.dataArr.count; //
}

//UIPickerViewDataSource中定义的方法，该方法的返回值决定该控件指定列包含多少个列表项
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    // 如果该控件只包含一列，因此无须理会列序号参数component
    // 该方法返回teams.count，表明teams包含多少个元素，该控件就包含多少行
    //    return self.dataArr[component].count;
    if(0 == component){
        return ROWNUM_HOUR;
    } else {
        return ROWNUM_MINUTE;
    }
    
}


// UIPickerViewDelegate中定义的方法，该方法返回的NSString将作为UIPickerView中指定列和列表项的标题文本
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    // 由于该控件只包含一列，因此无须理会列序号参数component
    // 该方法根据row参数返回teams中的元素，row参数代表列表项的编号，
    // 因此该方法表示第几个列表项，就使用teams中的第几个元素
    if(0 == component) {
        NSInteger index = row%24;
        return self.dataArr[component][index];
    } else {
        NSInteger index = row%60;
        return self.dataArr[component][index];
    }
    
    
}


// 当用户选中UIPickerViewDataSource中指定列和列表项时激发该方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:
(NSInteger)row inComponent:(NSInteger)component
{
    
//    if (<#condition#>) {
//        <#statements#>
//    } else {
//        <#statements#>
//    }
    switch (component) {
        case 0:
            self.firstIndex = row;
            break;
        case 1:
            self.secondIndex = row;
            break;
        default:
            break;
    }
    
    [self.pickerView reloadAllComponents];
    
//    NSString *day = self.dataArr[0][self.firstIndex];
    
    NSInteger firstIndex = self.firstIndex%24;
    NSInteger secondIndex = self.secondIndex%60;
    
    NSString *time = [NSString stringWithFormat:@"%@:%@",self.dataArr[0][firstIndex],self.dataArr[1][secondIndex]];
    self.selectedTime = time;
//    [self.delegate datePickerViewWithDate:day andTime:time];


    
    //    [self pickerViewLoaded:nil];
    //
    //    if (1 == component) {
    //        NSUInteger base10 = (max/2)-(max/2)%24;
    //        [self.pickerView selectRow:[self.pickerView selectedRowInComponent:0]%24+base10 inComponent:0 animated:false];
    //    } else if(1 == component) {
    //
    //    } else {
    //
    //    }
    
}

//-(void)pickerViewLoaded: (id)blah {
//    NSUInteger max = 16384;
//    NSUInteger base10 = (max/2)-(max/2)%24;
//    [self.pickerView selectRow:[self.pickerView selectedRowInComponent:0]%24+base10 inComponent:0 animated:false];
//}
// UIPickerViewDelegate中定义的方法，该方法返回的NSString将作为
// UIPickerView中指定列的宽度
-(CGFloat)pickerView:(UIPickerView *)pickerView
   widthForComponent:(NSInteger)component
{
    return 100;
    
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

//- (IBAction)clickCancelBtn:(id)sender {
//    
//    [self.delegate datePickerViewWithHidden];
//}
//- (IBAction)clickSureBtn:(id)sender {
//    
//    self.secondIndex = self.secondIndex%24;
//    self.thirdIndex = self.thirdIndex%60;
//    
//    NSString *day = self.dataArr[0][self.firstIndex];
//    NSString *time = [NSString stringWithFormat:@"%@:%@",self.dataArr[1][self.secondIndex],self.dataArr[2][self.thirdIndex]];
//    [self.delegate datePickerViewWithDate:day andTime:time];
//}


@end
