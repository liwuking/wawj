//
//  AddContactView.h
//  wawj
//
//  Created by ruiyou on 2017/11/2.
//  Copyright © 2017年 technology. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^AddContactViewAddNewContact) (void);
typedef void (^AddContactViewAddOldContact) (void);
typedef void (^AddContactViewAddHidden) (void);


@interface AddContactView : UIView
@property(nonatomic,copy)AddContactViewAddNewContact addContactViewAddNewContact;
@property(nonatomic,copy)AddContactViewAddOldContact addContactViewAddOldContact;
@property(nonatomic,copy)AddContactViewAddHidden addContactViewAddHidden;

@end
