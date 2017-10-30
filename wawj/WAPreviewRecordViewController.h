//
//  WAPreviewRecordViewController.h
//  wawj
//
//  Created by ruiyou on 2017/10/19.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WAPreviewRecordViewController : UIViewController

@property (strong, nonatomic)  NSString *headUrl;
@property (strong, nonatomic)  NSString *audioUrl;
@property(nonatomic,assign)    NSInteger recordedTime;
@property(nonatomic,assign)    NSString *recordedDate;

@end
