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
    
    self.cancelButton.layer.cornerRadius = 10;
    self.cancelButton.layer.masksToBounds = YES;
    
    self.galleryView.layer.cornerRadius = 10;
    self.galleryView.layer.masksToBounds = YES;
    
}

#pragma mark - Action

- (IBAction)actionCancel:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionChooseGallery:(id)sender {
    UIImagePickerController* vc = [[UIImagePickerController alloc] init];
    vc.delegate = self;

    vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    vc.allowsEditing = YES;
    self.imagePickerController =vc;
    [self presentViewController:vc animated:YES completion:nil];    
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
//    UIImage *image = info[UIImagePickerControllerOriginalImage];
//    if (image) {
//        self.selectedImage = image;
//        [self.imagePickerController dismissViewControllerAnimated:YES completion:^{
//
//
//        }];
//
//    }
    
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    CGFloat test = self.view.frame.size.width + self.view.frame.size.width/3;
    //NSLog(@"%f, %f", image.size.height, test);
    if (image.size.height < test) {
        image = info[UIImagePickerControllerOriginalImage];
        if (image) {
            self.selectedImage = image;
            [picker dismissViewControllerAnimated:YES completion:^{
                GalleryViewController* gvc = [self.storyboard instantiateViewControllerWithIdentifier:@"galleryController"];
                gvc.selectedImage = self.selectedImage;
                gvc.modalPresentationStyle = UIModalPresentationOverFullScreen;
                gvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                gvc.delegate = self;
                [self presentViewController:gvc animated:YES completion:nil];
            }];
        }
    } else {
        image = info[UIImagePickerControllerEditedImage];
        self.selectedImage = image;
        [picker dismissViewControllerAnimated:YES completion:^{
            GalleryViewController* gvc = [self.storyboard instantiateViewControllerWithIdentifier:@"galleryController"];
            gvc.selectedImage = self.selectedImage;
            gvc.modalPresentationStyle = UIModalPresentationOverFullScreen;
            gvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            gvc.delegate = self;
            [self presentViewController:gvc animated:YES completion:nil];
        }];

    }
    
//    UIImage *image = info[UIImagePickerControllerEditedImage];
//    if (image) {
//
//        self.selectedImage = image;
//        [picker dismissViewControllerAnimated:YES completion:^{
//            GalleryViewController* gvc = [self.storyboard instantiateViewControllerWithIdentifier:@"galleryController"];
//            gvc.selectedImage = self.selectedImage;
//            gvc.modalPresentationStyle = UIModalPresentationOverFullScreen;
//            gvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//            gvc.delegate = self;
//            [self presentViewController:gvc animated:YES completion:nil];
//        }];
//
//    } else {
//        image = info[UIImagePickerControllerOriginalImage];
//        if (image) {
//            self.selectedImage = image;
//            [picker dismissViewControllerAnimated:YES completion:^{
//                GalleryViewController* gvc = [self.storyboard instantiateViewControllerWithIdentifier:@"galleryController"];
//                gvc.selectedImage = self.selectedImage;
//                gvc.modalPresentationStyle = UIModalPresentationOverFullScreen;
//                gvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//                gvc.delegate = self;
//                [self presentViewController:gvc animated:YES completion:nil];
//            }];
//        }
//
//    }
//#warning HERE
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
