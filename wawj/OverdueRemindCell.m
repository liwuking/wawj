//
//  OverdueRemindCell.m
//  wawj
//
//  Created by ruiyou on 2017/10/10.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "OverdueRemindCell.h"

@implementation OverdueRemindCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)readAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(OverdueRemindCell:AndClickAudioIndexPath:)]) {
        [self.delegate OverdueRemindCell:self AndClickAudioIndexPath:self.cellIndexPath];
    }
}

@end
