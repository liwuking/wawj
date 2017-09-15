//
//  WAAddContactTableViewCell.h
//  wawj
//
//  Created by ruiyou on 2017/9/8.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WAAddContactTableViewCellDelegate <NSObject>

-(void)clickAddContact;

@end

@interface WAAddContactTableViewCell : UITableViewCell

@property(nonatomic, weak)id<WAAddContactTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;

@end
