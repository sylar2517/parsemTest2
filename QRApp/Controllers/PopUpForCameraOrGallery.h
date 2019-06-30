//
//  PopUpForCameraOrGallery.h
//  QRApp
//
//  Created by Сергей Семин on 24/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PopUpForCameraOrGallery : UIViewController

@property (weak, nonatomic) IBOutlet UIView *popUpView;

- (IBAction)actionCancel:(UIButton *)sender;
- (IBAction)actionChooseGallery:(id)sender;

@end

NS_ASSUME_NONNULL_END
