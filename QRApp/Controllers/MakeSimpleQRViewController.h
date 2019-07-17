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
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonsOutletCollection;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *levelConstrain;


- (IBAction)actionBack:(UIButton *)sender;
- (IBAction)actionExport:(UIButton *)sender;
- (IBAction)actionSaveImage:(UIButton *)sender;

@end

NS_ASSUME_NONNULL_END
