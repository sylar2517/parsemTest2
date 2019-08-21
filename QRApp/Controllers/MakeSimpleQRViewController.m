//
//  MakeSimpleQRViewController.m
//  QRApp
//
//  Created by Сергей Семин on 29/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "MakeSimpleQRViewController.h"
#import "QRPost+CoreDataClass.h"
#import "DataManager.h"

@interface MakeSimpleQRViewController ()

@end

@implementation MakeSimpleQRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    [self.tabBarController.tabBar setHidden:YES];
    
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

    if (self.view.frame.origin.y == 0) {
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
- (IBAction)actionBack:(UIButton *)sender {
    if (self.textField.text.length > 0) {
        QRPost* post = [NSEntityDescription insertNewObjectForEntityForName:@"QRPost" inManagedObjectContext:[DataManager sharedManager].persistentContainer.viewContext];
        NSDate* now = [NSDate date];
        post.dateOfCreation = now;
        post.type = @"Простой";
        post.value = self.textField.text;
        
        UIImage* image = self.resultImageView.image;
        
        UIGraphicsBeginImageContext(CGSizeMake(400, 400));
        [image drawInRect:CGRectMake(0, 0, 400, 400)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *imageData = UIImagePNGRepresentation(newImage);
        post.data = imageData;
        
        [[DataManager sharedManager] saveContext];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionExport:(UIButton *)sender {
    UIImage* image = self.resultImageView.image;
    
    UIGraphicsBeginImageContext(CGSizeMake(50, 50));
    [image drawInRect:CGRectMake(0, 0, 50, 50)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImagePNGRepresentation(newImage);
    
    NSArray* array = @[imageData];
    UIActivityViewController* avc = [[UIActivityViewController alloc] initWithActivityItems:array applicationActivities:nil];
    avc.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
    [self presentViewController:avc animated:YES completion:nil];
}

- (IBAction)actionSaveImage:(UIButton *)sender {

    UIImage* image = self.resultImageView.image;
    
    UIGraphicsBeginImageContext(CGSizeMake(400, 400));
    [image drawInRect:CGRectMake(0, 0, 400, 400)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil);
    
    UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"Сохранено" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction* aa = [UIAlertAction actionWithTitle:@"Ок" style:(UIAlertActionStyleCancel) handler:nil];
    [ac addAction:aa];
    [self presentViewController:ac animated:YES completion:nil];
    
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.textField resignFirstResponder];
}

#pragma matk -  UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([self.textField.text isEqual:nil] && self.textField.text.length > 0) {
        return YES;
    }
    [self makeQRFromString:self.textField.text];
    [self.textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    [self makeQRFromString:[textField.text stringByAppendingString:string]];
    return YES;
}
#pragma matk - private Methods
-(void)makeQRFromString:(NSString*)string{
    NSData *stringData = [string dataUsingEncoding: NSUTF8StringEncoding];
    
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
