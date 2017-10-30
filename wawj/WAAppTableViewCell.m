//
//  WAAppTableViewCell.m
//  wawj
//
//  Created by ruiyou on 2017/10/27.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "WAAppTableViewCell.h"
#import <UIImageView+WebCache.h>
@implementation WAAppTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.addBtn addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)setAppItem:(AppItem *)appItem {
    _appItem = appItem;
    
    [self.headImageUrl sd_setImageWithURL:[NSURL URLWithString:appItem.appIcoUrl] placeholderImage:[UIImage imageNamed:@"friends"]];
    self.titleLab.text = appItem.appName;
    
    if (appItem.isAdd) {
        [self.addBtn setTitle:@"添加" forState:UIControlStateNormal];
    } else {
        [self.addBtn setTitle:@"取消" forState:UIControlStateNormal];
    }
    
}


- (void)clickBtn {
    NSLog(@"%s",__FUNCTION__);
    self.appItem.isAdd = !self.appItem.isAdd;
    self.wAAppTableViewCellWithAddApp(self.appItem);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
