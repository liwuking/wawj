//
//  WAEditRemindTwoCell.h
//  wawj
//
//  Created by ruiyou on 2017/8/10.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef  void   (^switchStatus)(UISwitch *wSwitch);

@interface WAEditRemindTwoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UISwitch *wSwitch;

@property(nonatomic,copy) switchStatus waSwitchStatus;

@end
