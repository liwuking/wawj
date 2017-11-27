//
//  WASetOneCell.h
//  wawj
//
//  Created by ruiyou on 2017/8/1.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^clickLogin)(void);


@interface WASetOneCell : UITableViewCell
@property(nonatomic,copy)clickLogin  clickLogin;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLab;
@property (weak, nonatomic) IBOutlet UILabel *userIphone;

@end
