//
//  PopUpForCameraOrGallery.m
//  QRApp
//
//  Created by Сергей Семин on 24/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "PopUpForCameraOrGallery.h"
#import "GalleryViewController.h"
#import "QRViewController.h"
#import "HistoryScanTVController.h"

@interface PopUpForCameraOrGallery () <UINavigationControllerDelegate ,UIImagePickerControllerDelegate, GalleryViewControllerDelegate>

@property(strong, nonatomic)UIImagePickerController* imagePickerController;
@property(strong, nonatomic)UIImage* selectedImage;
@end

@implementation PopUpForCameraOrGallery

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.popUpView.layer.cornerRadius = 10;
    self.popUpView.layer.masksToBounds = YES;
    
}

#pragma mark - Action

- (IBAction)actionCancel:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionChooseGallery:(id)sender {
    UIImagePickerController* vc = [[UIImagePickerController alloc] init];
    vc.delegate = self;

    vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    vc.allowsEditing = NO;
    self.imagePickerController =vc;
    [self presentViewController:vc animated:YES completion:nil];    
}

- (IBAction)actionCamera:(UIButton *)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate presentCamera];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image) {
        self.selectedImage = image;
        [self.imagePickerController dismissViewControllerAnimated:YES completion:^{
            GalleryViewController* gvc = [self.storyboard instantiateViewControllerWithIdentifier:@"galleryController"];
            // UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:gvc];
            gvc.selectedImage = self.selectedImage;
            //[self presentViewController:gvc animated:YES completion:nil];
            //[]
            gvc.modalPresentationStyle = UIModalPresentationOverFullScreen;
            gvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            gvc.delegate = self;
            [self presentViewController:gvc animated:YES completion:nil];
//            UITabBarController* root = [self.storyboard instantiateViewControllerWithIdentifier:@"tapBarController"];
//            __weak PopUpForCameraOrGallery* weakSelf = self;
//            [self dismissViewControllerAnimated:NO completion:^{
//                [root presentViewController:gvc animated:YES completion:nil];
//            }];
        }];
    
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Navigation
- (void) exitCamera{
    [self dismissViewControllerAnimated:NO completion:nil];
}
@end
