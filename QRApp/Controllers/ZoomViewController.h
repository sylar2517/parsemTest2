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


@property (weak, nonatomic) IBOutlet UIButton *exitButton;

@property (weak, nonatomic) IBOutlet UIImageView *QRImageView;

- (IBAction)actionExtit:(UIButton *)sender;

@end

NS_ASSUME_NONNULL_END
