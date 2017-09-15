//
//  pickerView.h
//  Sign on
//
//  Created by 曾勇兵 on 15-1-28.
//  Copyright (c) 2015年 zengyongbing. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^GetPickerStr)(NSString *string);
#define PROVINCE_COMPONENT  0
#define CITY_COMPONENT      1
#define DISTRICT_COMPONENT  2


@interface pickerView :UIPickerView <UIPickerViewDelegate, UIPickerViewDataSource>
{

    NSString *filePath;
    NSDictionary *areaDic;
    NSArray *province;
    NSArray *city;
    NSArray *district;
    NSString *selectedProvince;
    
    NSString *documentType;//证件类型
    NSString *houseType;//
}

@property (nonatomic,strong)NSMutableDictionary *dic2;
//@property (nonatomic,strong)UIToolbar * accessoryView;
//@property (nonatomic,strong)UIToolbar * accessory2View;
//@property (nonatomic,strong)UIDatePicker *customInput;
//@property (nonatomic,strong)UIPickerView *pickerViewe;

@property (nonatomic,copy)GetPickerStr getStr;

- (void)picRegion;

@end
