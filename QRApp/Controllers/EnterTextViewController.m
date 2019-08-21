//
//  EnterTextViewController.m
//  QRApp
//
//  Created by Сергей Семин on 18/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "EnterTextViewController.h"
//#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>

@interface EnterTextViewController () <UITextViewDelegate, CNContactPickerDelegate>

@end

@implementation EnterTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Disign
    self.secondView.layer.cornerRadius = 10;
    self.secondView.layer.masksToBounds = YES;
    
    self.commitButton.layer.cornerRadius = 10;
    self.commitButton.layer.masksToBounds = YES;
    
    self.backButton.layer.cornerRadius = 10;
    self.backButton.layer.masksToBounds = YES;
    
    self.textView.layer.cornerRadius = 10;
    self.textView.layer.masksToBounds = YES;
    

    self.constrainForTel.constant = 21;
    
    if (self.startString) {
        self.textView.text = self.startString;
    }
    self.textView.delegate = self;
    self.contactButton.hidden = YES;
    if (self.type) {
        if ([self.type isEqualToString:@"text"]) {
            self.textView.keyboardType = UIKeyboardTypeDefault;
            [self makeHiddenFrom:@"text"];
            
        } else if ([self.type isEqualToString:@"mail"]) {
            self.textView.keyboardType = UIKeyboardTypeEmailAddress;
            [self makeHiddenFrom:@"text"];
            
        } else if ([self.type isEqualToString:@"url"]){
            self.textView.keyboardType = UIKeyboardTypeURL;
            [self makeHiddenFrom:@"text"];
            
        } else if ([self.type isEqualToString:@"date"]){
            self.datePicker.layer.cornerRadius = 10;
            self.datePicker.layer.masksToBounds = YES;
            self.datePicker.backgroundColor = [UIColor lightGrayColor];
            self.datePicker.tintColor = [UIColor whiteColor];
            [self makeHiddenFrom:@"date"];
            
        }   else if ([self.type isEqualToString:@"phone"]){
            self.textView.keyboardType = UIKeyboardTypeNumberPad;
            self.constrainForTel.constant = 135;
            self.contactButton.layer.cornerRadius = 10;
            self.contactButton.layer.masksToBounds = YES;
            self.contactButton.hidden = NO;
            [self makeHiddenFrom:@"text"];
            
        }
    }

    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (CGRectGetWidth(screenBounds) == 320) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - NSNotificationCenter
-(void)keyboardWillAppear:(NSNotification*)notification{
    
    if (self.view.frame.origin.y == 0) {
        [UIView animateWithDuration:0.25 animations:^{
            self.constrainForSE.constant = 25;
        }];
    }
}
-(void)keyboardWillDisappear:(NSNotification*)notification{
    [UIView animateWithDuration:0.25 animations:^{
        self.constrainForSE.constant = 85;
    }];
}
#pragma mark - touches
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.textView resignFirstResponder];
}
 #pragma mark - Action
- (IBAction)actionDone:(UIButton *)sender {
    
    if (self.textView.text.length == 0 || [self.textView.text isEqualToString:self.startString]) {
        if (!self.textView.hidden) {
            UIAlertController* ac = [UIAlertController alertControllerWithTitle:self.startString message:nil preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction* aa = [UIAlertAction actionWithTitle:@"Ок" style:(UIAlertActionStyleCancel) handler:nil];
            [ac addAction:aa];
            [self presentViewController:ac animated:YES completion:nil];
        }
    } else {
        if (!self.textView.hidden) {
            [self.textView resignFirstResponder];
            [self.delegate textTransfer:self.textView.text forType:self.type];
        } else {
            NSDateFormatter* df = [[NSDateFormatter alloc] init];
            [df setDateStyle:(NSDateFormatterShortStyle)];
            NSString* string = [df stringFromDate:self.datePicker.date];
            [self.delegate textTransfer:string forType:self.type];
        }
      
        CATransition *transition = [[CATransition alloc] init];
        transition.duration = 0.5;
        transition.type = kCATransitionFade;
        transition.subtype = kCATransitionFromTop;
        [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [self.view.window.layer addAnimation:transition forKey:kCATransition];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    
    
}

- (IBAction)actionBack:(UIButton *)sender {
    [self.textView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionAddContact:(UIButton *)sender {
    CNEntityType entityType = CNEntityTypeContacts;
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:entityType];
    
    if (status == CNAuthorizationStatusNotDetermined) {
        
        CNContactStore* store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:entityType completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                [self openContact];
            } else {
                NSLog(@"Not authorized");
            }
        }];
        
    } else if (status == CNAuthorizationStatusAuthorized) {
        [self openContact];
    }
    
}

-(void)openContact{
    CNContactPickerViewController* vc = [[CNContactPickerViewController alloc] init];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}
#pragma mark - CNContactPickerDelegate
- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact{
    
    NSArray* phoneNumbers = contact.phoneNumbers;
    UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"Выберете номер" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
   
    
    if (phoneNumbers.count > 1) {
        for (CNLabeledValue* number in phoneNumbers) {
            CNPhoneNumber* phone = number.value;
            UIAlertAction* add = [UIAlertAction actionWithTitle:phone.stringValue style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                self.textView.text =  phone.stringValue;
            }];
            [ac addAction:add];
        }
        
        [picker dismissViewControllerAnimated:YES completion:^{
            [self presentViewController:ac animated:YES completion:nil];
        }];
        
    } else {
        CNLabeledValue* number = [phoneNumbers firstObject];;
        CNPhoneNumber* phone = number.value;
        self.textView.text =  phone.stringValue;
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    
}
#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    //self.textView.text = @"";
    if ([textView.text rangeOfString:@"Введите"].location != NSNotFound) {
        textView.text = @"";
    }
    return YES;
}

#pragma mark - Methods
- (void)makeHiddenFrom:(NSString*)string{
    if ([string isEqualToString:@"text"]) {
        self.datePicker.hidden = YES;
        self.textView.hidden = NO;
    } else if ([string isEqualToString:@"date"]){
        self.datePicker.hidden = NO;
        self.textView.hidden = YES;
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([self.type isEqualToString:@"phone"]) {
        NSLog(@"%@", [textView.text stringByAppendingString:text]);
    }
    return YES;
}
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//    //NSCharacterSet* validationSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
////    NSArray* components =[text componentsSeparatedByCharactersInSet:validationSet];
//    NSMutableCharacterSet* alnum = [NSMutableCharacterSet characterSetWithCharactersInString:@"_"];
//    [alnum formUnionWithCharacterSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
//    NSArray* components =[text componentsSeparatedByCharactersInSet:alnum];
////    NSCharacterSet* validationSet2 = [NSCharacterSet characterSetWithCharactersInString:@"+"];
////    NSArray* components2 =[text componentsSeparatedByCharactersInSet:validationSet2];
//    if ([components count] > 1){
//        return NO;
//    } else {
//        return YES;
//    }
//    
////    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
////    NSLog(@"new string - %@", newString);
////
////    NSArray *validComponents = [newString componentsSeparatedByCharactersInSet:validationSet];
////    newString = [validComponents componentsJoinedByString:@""];
////    NSLog(@"new string fixed = %@", newString);
////
////    static const int localNuberMaxLength = 7;
////    static const int areaCodeMaxLengh = 3;
////    static const int countryCodeMaxLengh = 4;
////
////    if ([newString length] > localNuberMaxLength + areaCodeMaxLengh + countryCodeMaxLengh) {
////        return NO;
////    }
////
////    NSMutableString *resultString = [NSMutableString string];
////    NSInteger localNuberLength = MIN([newString length], localNuberMaxLength);
////
////    if (localNuberLength > 0) {
////        NSString *number = [newString substringFromIndex:(int)[newString length]-localNuberLength];
////        [resultString appendString:number];
////        if ([resultString length] >3) {
////            [resultString insertString:@"-" atIndex:3];
////        }
////    }
////
////    if ([newString length] > localNuberMaxLength) {
////        NSInteger areaCodeLengh = MIN((int)[newString length] - localNuberMaxLength, areaCodeMaxLengh);
////        NSRange areaRage = NSMakeRange((int)[newString length] - localNuberMaxLength - areaCodeLengh, areaCodeLengh);
////        NSString* area = [newString substringWithRange:areaRage];
////        area = [NSString stringWithFormat:@"(%@) ", area];
////        [resultString insertString:area atIndex:0];
////    }
////
////    if ([newString length] > localNuberMaxLength + areaCodeMaxLengh) {
////        NSInteger countryCodeLengh = MIN((int)[newString length] - localNuberMaxLength - areaCodeMaxLengh, countryCodeMaxLengh);
////        NSRange countryRage = NSMakeRange(0, countryCodeLengh);
////        NSString* countryCode = [newString substringWithRange:countryRage];
////        countryCode = [NSString stringWithFormat:@"+%@ ", countryCode];
////        [resultString insertString:countryCode atIndex:0];
////    }
////
////    //так над, ввести собственноручно
////    textView.text = resultString;
////    return NO;
//}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
