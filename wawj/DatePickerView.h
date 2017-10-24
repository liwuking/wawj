//
//  DatePickerView.h
//  wawj
//
//  Created by ruiyou on 2017/10/19.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DatePickerViewDelegate <NSObject>

- (void)datePickerViewWithDate:(NSString *)day andTime:(NSString *)time;

- (void)datePickerViewWithHidden;

@end

@interface DatePickerView : UIView

@property(nonatomic, weak)id<DatePickerViewDelegate> delegate;
@property(nonatomic,strong)NSString *currentTime;
@property(nonatomic,strong)NSString *dayTime;

@end
