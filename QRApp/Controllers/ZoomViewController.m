//
//  ZoomViewController.m
//  QRApp
//
//  Created by Сергей Семин on 24/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "ZoomViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ZoomViewController ()

@end

@implementation ZoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if (self.transferedImage) {
        self.exitButton.layer.cornerRadius = 15;
        self.exitButton.layer.masksToBounds = YES;
        self.QRImageView.layer.magnificationFilter = kCAFilterNearest;
        self.QRImageView.image = self.transferedImage;
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }

    if (self.isContact) {
        self.exportButton.layer.cornerRadius = 15;
        self.exportButton.layer.masksToBounds = YES;
        self.exportButton.hidden = NO;
        
        self.saveButton.layer.cornerRadius = 15;
        self.saveButton.layer.masksToBounds = YES;
        self.saveButton.hidden = NO;
    }
    
}



- (IBAction)actionExtit:(UIButton *)sender {
     [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionSave:(UIButton *)sender {
    UIImage* image = self.QRImageView.image;
    
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

- (IBAction)actionExport:(UIButton *)sender {
    
    UIImage* image = self.QRImageView.image;
    
    UIGraphicsBeginImageContext(CGSizeMake(400, 400));
    [image drawInRect:CGRectMake(0, 0, 400, 400)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImagePNGRepresentation(newImage);
    
    NSArray* array = @[imageData];
    UIActivityViewController* avc = [[UIActivityViewController alloc] initWithActivityItems:array applicationActivities:nil];
    avc.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
    [self presentViewController:avc animated:YES completion:nil];
    
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
