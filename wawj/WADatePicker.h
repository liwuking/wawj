//
//  WADatePicker.h
//  wawj
//
//  Created by ruiyou on 2017/8/10.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WADatePicker;

@protocol WADatePickerDelegate <NSObject>

-(void)WADatePickerWithSure:(WADatePicker *)datePicker;
-(void)WADatePickerWithCancel:(WADatePicker *)datePicker;

@end

@interface WADatePicker : UIView

@property(nonatomic,weak)id<WADatePickerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *clickChacha;
@property (weak, nonatomic) IBOutlet UIButton *clickDuigou;
@property (weak, nonatomic) IBOutlet UILabel *timeText;

@end
