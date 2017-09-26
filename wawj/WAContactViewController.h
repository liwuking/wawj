//
//  WAContactViewController.h
//  wawj
//
//  Created by ruiyou on 2017/9/8.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol WAContactViewControllerDelegate <NSObject>
//
//-(void)waContactViewControllerRefreshData;
//
//@end

@interface WAContactViewController : UIViewController

//@property(nonatomic, weak)id<WAContactViewControllerDelegate> delegate;

@property(nonatomic, strong)NSString *contacts;

@end
