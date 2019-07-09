//
//  TextScanViewController.h
//  QRApp
//
//  Created by Сергей Семин on 06/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TextScanViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *settingsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstrain;

@property (weak, nonatomic) IBOutlet UIButton *textScanButton;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;


- (IBAction)flashONorOFF:(UIButton *)sender;
- (IBAction)actionScan:(UIButton *)sender;
- (IBAction)actionExit:(UIButton *)sender;
- (IBAction)backToQR:(UIButton *)sender;


@end

NS_ASSUME_NONNULL_END
