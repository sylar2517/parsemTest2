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

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actionExtit:(UIButton *)sender {
     [self dismissViewControllerAnimated:YES completion:nil];
}
@end
