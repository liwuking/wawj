//
//  contactView.h
//  wawj
//
//  Created by ruiyou on 2017/9/12.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol contactViewDelegate <NSObject>

-(void)clickContactViewWith:(NSString *)str;

@end

@interface contactView : UIView

@property(weak,nonatomic) id<contactViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;

@end
