//
//  QRPopViewController.h
//  QRApp
//
//  Created by Сергей Семин on 01/08/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class QRPopViewController;
@protocol QRPopViewControllerDelegate
- (void)transferImage:(UIImage*)image fromBackground:(BOOL)background;
@end

@interface QRPopViewController : UIViewController

@property(assign, nonatomic)BOOL isBackground;
@property (nonatomic, weak) id <QRPopViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView * popView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIView * galleryButton;
@property (weak, nonatomic) IBOutlet UIView * camButton;

- (IBAction)actionCancel:(UIButton *)sender;
- (IBAction)actionTakePhoto:(UIButton *)sender;
- (IBAction)actionFromGall:(UIButton *)sender;



@end

NS_ASSUME_NONNULL_END
