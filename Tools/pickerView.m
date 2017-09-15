//
//  pickerView.m
//  Sign on
//
//  Created by 曾勇兵 on 15-1-28.
//  Copyright (c) 2015年 zengyongbing. All rights reserved.
//

#import "pickerView.h"

@implementation pickerView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    

    [self picRegion];
    
    return self;
}




#pragma - mark 地区选择
- (void)picRegion
{
    self.delegate = self;
    self.dataSource = self;
    self.showsSelectionIndicator = YES;
    
    
    NSString *plist = [[NSBundle mainBundle]pathForResource:@"area" ofType:@"plist"]
    ;
    areaDic = [[NSDictionary alloc]initWithContentsOfFile:plist];
    
    NSArray *components = [areaDic allKeys];
    NSArray *sortedArray = [components sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    NSMutableArray *provinceTmp = [[NSMutableArray alloc]init];
    for (int i=0; i<[sortedArray count]; i++) {
        NSString *index = [sortedArray objectAtIndex:i];
        NSArray *tmp = [[areaDic objectForKey:index]allKeys];
        [provinceTmp addObject:[tmp objectAtIndex:0]];
        
    }
    
    province = [[NSArray alloc] initWithArray: provinceTmp];
    
    NSString *index = [sortedArray objectAtIndex:0];
    NSString *selected = [province objectAtIndex:0];
    NSDictionary *dic = [NSDictionary dictionaryWithDictionary: [[areaDic objectForKey:index]objectForKey:selected]];
    
    NSArray *cityArray = [dic allKeys];
    NSDictionary *cityDic = [NSDictionary dictionaryWithDictionary: [dic objectForKey: [cityArray objectAtIndex:0]]];
    city = [[NSArray alloc] initWithArray: [cityDic allKeys]];
    
    
    NSString *selectedCity = [city objectAtIndex: 0];
    district = [[NSArray alloc] initWithArray: [cityDic objectForKey: selectedCity]];
    
    
    
    selectedProvince = [province objectAtIndex: 0];
    
    
    
}


#pragma mark- Picker Data Source Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == PROVINCE_COMPONENT) {
        return [province count];
    }
    else if (component == CITY_COMPONENT) {
        return [city count];
    }
    else {
        return [district count];
    }
}


#pragma mark- Picker Delegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == PROVINCE_COMPONENT) {
        return [province objectAtIndex: row];
    }
    else if (component == CITY_COMPONENT) {
        return [city objectAtIndex: row];
    }
    else {
        return [district objectAtIndex: row];
    }
    
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == PROVINCE_COMPONENT) {
        selectedProvince = [province objectAtIndex: row];
        NSDictionary *tmp = [NSDictionary dictionaryWithDictionary: [areaDic objectForKey: [NSString stringWithFormat:@"%ld", (long)row]]];
        NSDictionary *dic = [NSDictionary dictionaryWithDictionary: [tmp objectForKey: selectedProvince]];
        NSArray *cityArray = [dic allKeys];
        NSArray *sortedArray = [cityArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
            
            if ([obj1 integerValue] > [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedDescending;//递减
            }
            
            if ([obj1 integerValue] < [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedAscending;//上升
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (int i=0; i<[sortedArray count]; i++) {
            NSString *index = [sortedArray objectAtIndex:i];
            NSArray *temp = [[dic objectForKey: index] allKeys];
            [arr addObject: [temp objectAtIndex:0]];
            
            
        }
        
        
        city = [[NSArray alloc] initWithArray: arr];
        
        NSDictionary *cityDic = [dic objectForKey: [sortedArray objectAtIndex: 0]];
        district = [[NSArray alloc] initWithArray: [cityDic objectForKey: [city objectAtIndex: 0]]];
        [pickerView selectRow: 0 inComponent: CITY_COMPONENT animated: YES];
        [pickerView selectRow: 0 inComponent: DISTRICT_COMPONENT animated: YES];
        [pickerView reloadComponent: CITY_COMPONENT];
        [pickerView reloadComponent: DISTRICT_COMPONENT];
        
    }
    else if (component == CITY_COMPONENT) {
        NSString *provinceIndex = [NSString stringWithFormat: @"%lu", (unsigned long)[province indexOfObject: selectedProvince]];
        NSDictionary *tmp = [NSDictionary dictionaryWithDictionary: [areaDic objectForKey: provinceIndex]];
        NSDictionary *dic = [NSDictionary dictionaryWithDictionary: [tmp objectForKey: selectedProvince]];
        NSArray *dicKeyArray = [dic allKeys];
        NSArray *sortedArray = [dicKeyArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
            
            if ([obj1 integerValue] > [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if ([obj1 integerValue] < [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        NSDictionary *cityDic = [NSDictionary dictionaryWithDictionary: [dic objectForKey: [sortedArray objectAtIndex: row]]];
        NSArray *cityKeyArray = [cityDic allKeys];
        
        
        district = [[NSArray alloc] initWithArray: [cityDic objectForKey: [cityKeyArray objectAtIndex:0]]];
        [pickerView selectRow: 0 inComponent: DISTRICT_COMPONENT animated: YES];
        [pickerView reloadComponent: DISTRICT_COMPONENT];
    }
    
    
    
    NSInteger provinceIndex = [pickerView selectedRowInComponent: PROVINCE_COMPONENT];
    NSInteger cityIndex = [pickerView selectedRowInComponent: CITY_COMPONENT];
    NSInteger districtIndex = [pickerView selectedRowInComponent: DISTRICT_COMPONENT];
    
    NSString *provinceStr = [province objectAtIndex: provinceIndex];
    
    NSString *cityStr = [city objectAtIndex: cityIndex];
    
    NSString *districtStr = [district objectAtIndex:districtIndex];
    
    NSString *address = [NSString stringWithFormat:@"%@,%@,%@",provinceStr,cityStr,districtStr];
    if (_getStr !=nil) {
        self.getStr(address);
    }
    
//    NSRange rang3 = [provinceStr rangeOfString:@"北京市"];
//    NSRange rang4 = [provinceStr rangeOfString:@"上海市"];
//    NSRange rang5 = [provinceStr rangeOfString:@"天津市"];
//    NSRange rang6 = [provinceStr rangeOfString:@"重庆市"];
    
//    NSString * s = [address substringFromIndex:3];
    
    //    else if (rang3.location !=NSNotFound){
//        
//        self.getStr(s);
//        
//    }else if (rang4.location !=NSNotFound){
//        
//        self.getStr(s);
//        
//    }else if (rang5.location !=NSNotFound){
//        
//        self.getStr(s);
//        
//    }else if (rang6.location !=NSNotFound){
//        
//        self.getStr(s);
//        
//    }
//    else {
    
    
//    }
    
//    if([provinceStr isEqualToString:@"香港特别行政区"]) {
//        
//        self.getStr(@"香港特别行政区");
//        
//    }else if ([provinceStr isEqualToString:@"澳门特别行政区"]) {
//        
//        self.getStr(@"澳门特别行政区");
//        
//    }
    
    
    
    
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (component == PROVINCE_COMPONENT) {
        return 100;
    }
    else if (component == CITY_COMPONENT) {
        return 100;
    }
    else {
        return 100;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *myView= nil;
    
    
    if (component == PROVINCE_COMPONENT) {
        myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 130, 40)];
        myView.textAlignment = NSTextAlignmentCenter;
        myView.text = [province objectAtIndex:row];
        myView.font = [UIFont boldSystemFontOfSize:14];
        myView.backgroundColor = [UIColor clearColor];
    }else if (component == CITY_COMPONENT) {
        myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 180, 40)];
        myView.textAlignment = NSTextAlignmentCenter;
        myView.text = [city objectAtIndex:row];
        myView.font = [UIFont boldSystemFontOfSize:14];
        myView.backgroundColor = [UIColor clearColor];
        
        
    }else if (component == DISTRICT_COMPONENT){
        myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 190, 40)];
        myView.textAlignment = NSTextAlignmentCenter;
        myView.text = [district objectAtIndex:row];
        myView.font = [UIFont boldSystemFontOfSize:14];
        myView.backgroundColor = [UIColor clearColor];
        
        
    }
    
    return myView;
}


@end
