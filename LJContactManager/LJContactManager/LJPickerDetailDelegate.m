//
//  LJPickerDetailDelegate.m
//  Demo
//
//  Created by LeeJay on 2017/4/24.
//  Copyright © 2017年 LeeJay. All rights reserved.
//

#import "LJPickerDetailDelegate.h"

@implementation LJPickerDetailDelegate 

#pragma mark - ABPeoplePickerNavigationControllerDelegate

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
                         didSelectPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    NSString *name = CFBridgingRelease(ABRecordCopyCompositeName(person));
    
    ABMultiValueRef multi = ABRecordCopyValue(person, kABPersonPhoneProperty);
    long index = ABMultiValueGetIndexForIdentifier(multi, identifier);
    NSString *phone = CFBridgingRelease(ABMultiValueCopyValueAtIndex(multi, index));
    CFRelease(multi);
    
    CFDataRef imageDataRef = ABPersonCopyImageDataWithFormat(person,kABPersonImageFormatThumbnail);
    
    NSData *imageData = (__bridge NSData*)imageDataRef;
    
    if (self.handler)
    {
        self.handler(name, phone,imageData);
    }
    
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CNContactPickerDelegate

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact {
    NSString *name = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
    
    NSString *phoneNumber = @"";
    if (contact.phoneNumbers.count) {
        CNLabeledValue *labeledValue= contact.phoneNumbers[0];
        phoneNumber = [labeledValue.value stringValue];
    }
    
    //缩略图Data
    NSData * thumImageData = nil;
    if ([contact isKeyAvailable:CNContactThumbnailImageDataKey])
    {
        thumImageData = contact.thumbnailImageData;
    }
    
    if (self.handler)
    {
        self.handler(name, phoneNumber,thumImageData);
    }
}
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty
{
    CNContact *contact = contactProperty.contact;
    NSString *name = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
    CNPhoneNumber *phoneValue= contactProperty.value;
    NSString *phoneNumber = phoneValue.stringValue;
    
    if (self.handler)
    {
        self.handler(name, phoneNumber,contact.imageData);
    }
}

@end
