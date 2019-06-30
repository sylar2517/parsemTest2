//
//  MakeSimpleQRViewController.h
//  QRApp
//
//  Created by Сергей Семин on 29/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MakeSimpleQRViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *resultImageView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIView *menuView;


- (IBAction)actionEndOfPrint:(UITextField *)sender;
- (IBAction)actionBack:(UIButton *)sender;
- (IBAction)actionPrint:(UITextField *)sender;

@end

NS_ASSUME_NONNULL_END
