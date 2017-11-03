//
//  AddContactView.m
//  wawj
//
//  Created by ruiyou on 2017/11/2.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "AddContactView.h"

@implementation AddContactView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    self.addContactViewAddHidden();
    
}
- (IBAction)clickCancel:(UIButton *)sender {
     self.addContactViewAddHidden();
}

- (IBAction)clickAddNewContact:(UIButton *)sender {
    self.addContactViewAddNewContact();
}
- (IBAction)clickOldContact:(UIButton *)sender {
    self.addContactViewAddOldContact();
}

@end
