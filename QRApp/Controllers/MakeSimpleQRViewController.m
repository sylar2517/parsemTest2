//
//  MakeSimpleQRViewController.m
//  QRApp
//
//  Created by Сергей Семин on 29/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "MakeSimpleQRViewController.h"

@interface MakeSimpleQRViewController ()

@end

@implementation MakeSimpleQRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    for (UIButton* but in self.buttonsOutletCollection) {
        but.layer.cornerRadius = 10;
        but.layer.masksToBounds = YES;
    }
    self.menuView.layer.cornerRadius = 10;
    self.menuView.layer.masksToBounds = YES;
    
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
//    NSNumber* test = [notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
//    CGRect rect = [test CGRectValue];
  //  NSLog(@"%@", notification.userInfo);
    if (self.view.frame.origin.y == 0) {
        //self.levelConstrain.constant = -CGRectGetHeight(rect);
        
        [UIView animateWithDuration:0.25 animations:^{
            self.levelConstrain.constant = -50;
        }];
    }
}
-(void)keyboardWillDisappear:(NSNotification*)notification{
    [UIView animateWithDuration:0.25 animations:^{
        self.levelConstrain.constant = 0;
    }];
}

#pragma mark - Actions
- (IBAction)actionEndOfPrint:(UITextField *)sender {
    [self makeQR];
}

- (IBAction)actionBack:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionExport:(UIButton *)sender {
}

- (IBAction)actionSaveImage:(UIButton *)sender {
//    UIImage* image = [self makeQRForSaveOrExport];
//    
//    UIGraphicsBeginImageContext(CGSizeMake(400, 400));
//    image = UIGraphicsGetImageFromCurrentImageContext();
////    image = [self makeQRForSaveOrExport];
//    UIGraphicsEndImageContext();
//    UIImageView* imageview = [[UIImageView alloc] initWithImage:image];
//    [self.view addSubview:imageview];
//    //NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
//    NSLog(@"%@", image);
////    NSArray* array = @[image];
////    UIActivityViewController* avc = [[UIActivityViewController alloc] initWithActivityItems:array applicationActivities:nil];
////    //avc.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
//    [self presentViewController:avc animated:YES completion:nil];

    
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.textField resignFirstResponder];
}

#pragma matk -  UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([self.textField.text isEqual:nil]) {
        return YES;
    }
    [self makeQR];
    [self.textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

//    if (textField.text.length == 1 && [string isEqualToString:@""]) {
//    
//    }
    [self makeQR];
    return YES;
}
#pragma matk - private Methods
-(void)makeQR{
    NSData *stringData = [self.textField.text dataUsingEncoding: NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrImage = qrFilter.outputImage;
    float scaleX = self.resultImageView.frame.size.width / qrImage.extent.size.width;
    float scaleY = self.resultImageView.frame.size.height / qrImage.extent.size.height;
    
    qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];
    
    self.resultImageView.image = [UIImage imageWithCIImage:qrImage
                                                     scale:[UIScreen mainScreen].scale
                                               orientation:UIImageOrientationUp];
}
-(UIImage*)makeQRForSaveOrExport{
    NSData *stringData = [self.textField.text dataUsingEncoding: NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrImage = qrFilter.outputImage;
    float scaleX = self.resultImageView.frame.size.width / qrImage.extent.size.width;
    float scaleY = self.resultImageView.frame.size.height / qrImage.extent.size.height;
    
    qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];
    
    return  [UIImage imageWithCIImage:qrImage
                             scale:[UIScreen mainScreen].scale
                       orientation:UIImageOrientationUp];
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
