//
//  WASetTwoCell.h
//  wawj
//
//  Created by ruiyou on 2017/8/1.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SwitchState)(BOOL state);

@interface WASetTwoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UISwitch *waSwitch;
@property(nonatomic,copy)SwitchState  switchState;
@end
