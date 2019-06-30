//
//  GalleryViewController.h
//  QRApp
//
//  Created by Сергей Семин on 25/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GalleryViewController : UIViewController
@property(strong, nonatomic)UIImage* selectedImage;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;




- (IBAction)actionCopy:(UIButton *)sender;
- (IBAction)actionScan:(UIButton *)sender;



@end

NS_ASSUME_NONNULL_END
