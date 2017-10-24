//
//  TimePickerView.h
//  wawj
//
//  Created by ruiyou on 2017/10/23.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimePickerViewDelegate <NSObject>

- (void)datePickerViewWithDate:(NSString *)day andTime:(NSString *)time;

@end

@interface TimePickerView : UIView

@property(nonatomic, weak)id<TimePickerViewDelegate> delegate;
@property(nonatomic,strong)NSString *currentTime;
@property (nonatomic,strong,readonly)NSString *selectedTime;
@property(nonatomic,assign)BOOL isEnble;

@end
