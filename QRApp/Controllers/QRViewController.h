//
//  ViewController.h
//  QRApp
//
//  Created by Сергей Семин on 24/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *toolBarView;
@property (weak, nonatomic) IBOutlet UIButton *QRScanButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewQR;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *buttons;
@property (weak, nonatomic) IBOutlet UIButton *backButton;


- (IBAction)actionFlashOnCliked:(UIButton *)sender;
- (IBAction)actionScanQR:(UIButton *)sender;
- (IBAction)actionScanPDF:(UIButton *)sender;

- (IBAction)actionBarcode:(UIButton *)sender;
- (IBAction)scanText:(UIButton *)sender;
- (IBAction)actionExit:(UIButton *)sender;

//-(void)backToRoot;
@end

