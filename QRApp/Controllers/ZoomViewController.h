//
//  ZoomViewController.h
//  QRApp
//
//  Created by Сергей Семин on 24/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZoomViewController : UIViewController

@property(strong, nonatomic)UIImage* transferedImage;
@property(assign, nonatomic)BOOL isContact;

@property (weak, nonatomic) IBOutlet UIButton *exitButton;

@property (weak, nonatomic) IBOutlet UIImageView *QRImageView;
@property (weak, nonatomic) IBOutlet UIButton *exportButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;




- (IBAction)actionExtit:(UIButton *)sender;
- (IBAction)actionSave:(UIButton *)sender;
- (IBAction)actionExport:(UIButton *)sender;
@end

NS_ASSUME_NONNULL_END
