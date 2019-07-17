//
//  EnterTextViewController.m
//  QRApp
//
//  Created by Сергей Семин on 18/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "EnterTextViewController.h"

@interface EnterTextViewController () <UITextViewDelegate>

@end

@implementation EnterTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.secondView.layer.cornerRadius = 10;
    self.secondView.layer.masksToBounds = YES;
    
    self.commitButton.layer.cornerRadius = 10;
    self.commitButton.layer.masksToBounds = YES;
    
    self.backButton.layer.cornerRadius = 10;
    self.backButton.layer.masksToBounds = YES;
    
    self.textView.layer.cornerRadius = 10;
    self.textView.layer.masksToBounds = YES;
    
    if (self.startString) {
        self.textView.text = self.startString;
    }
    self.textView.delegate = self;
    
    if (self.type) {
        if ([self.type isEqualToString:@"mail"]) {
            self.textView.keyboardType = UIKeyboardTypeEmailAddress;
        } else if ([self.type isEqualToString:@"url"]){
            self.textView.keyboardType = UIKeyboardTypeURL;
        }
    }

    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (CGRectGetWidth(screenBounds) == 320) {
        NSLog(@"AaaaaAaaaaAaaaaAaaaaAaaaaAaaaaAaaaa");
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

 #pragma mark - Action
- (IBAction)actionDone:(UIButton *)sender {
    
    if (self.textView.text.length == 0 || [self.textView.text isEqualToString:self.startString]) {
        UIAlertController* ac = [UIAlertController alertControllerWithTitle:self.startString message:nil preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction* aa = [UIAlertAction actionWithTitle:@"Ок" style:(UIAlertActionStyleCancel) handler:nil];
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
    } else {
        [self.textView resignFirstResponder];
        [self.delegate textTransfer:self.textView.text];
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
#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    self.textView.text = @"";
    
    return YES;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
