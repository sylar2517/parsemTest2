//
//  QRPopViewController.m
//  QRApp
//
//  Created by Сергей Семин on 01/08/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "QRPopViewController.h"

@interface QRPopViewController () <UINavigationControllerDelegate , UIImagePickerControllerDelegate>

@property(strong, nonatomic)UIImage* selectedImage;
@property(strong, nonatomic)UIImagePickerController* imagePickerController;

@end

@implementation QRPopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.popView.layer.cornerRadius = 10;
    self.popView.layer.masksToBounds = YES;
    
    self.cancelButton.layer.cornerRadius = 10;
    self.cancelButton.layer.masksToBounds = YES;
    
    self.galleryButton.layer.cornerRadius = 10;
    self.galleryButton.layer.masksToBounds = YES;
    
    self.camButton.layer.cornerRadius = 10;
    self.camButton.layer.masksToBounds = YES;
  
}
- (IBAction)actionCancel:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)actionTakePhoto:(UIButton *)sender{
    UIImagePickerController* vc = [[UIImagePickerController alloc] init];
    vc.delegate = self;
    vc.sourceType = UIImagePickerControllerSourceTypeCamera;
    vc.allowsEditing = YES;
    self.imagePickerController =vc;
    [self presentViewController:vc animated:YES completion:nil];
    
}
- (IBAction)actionFromGall:(UIButton *)sender{
    UIImagePickerController* vc = [[UIImagePickerController alloc] init];
    vc.delegate = self;
    vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    vc.allowsEditing = YES;
    self.imagePickerController =vc;
    [self presentViewController:vc animated:YES completion:nil];   
    
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (image) {
        self.selectedImage = image;
        [picker dismissViewControllerAnimated:YES completion:^{
            
            //__weak __block QRPopViewController* weakSelf = self;
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.delegate transferImage:image fromBackground:self.isBackground];
            
            
            
        }];
        
    } else {
        image = info[UIImagePickerControllerOriginalImage];
        if (image) {
            self.selectedImage = image;
            [picker dismissViewControllerAnimated:YES completion:^{
                
                [self dismissViewControllerAnimated:YES completion:nil];
                [self.delegate transferImage:image fromBackground:self.isBackground];
                
                
            }];
        }
        
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    CGPoint pointOnMainView = [touch locationInView:self.view];
    
    if (!CGRectContainsPoint(self.popView.frame, pointOnMainView)) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
