//
//  CustomQRTableViewController.h
//  QRApp
//
//  Created by Сергей Семин on 18/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomQRTableViewController : UITableViewController
@property(strong, nonatomic)NSString*titleText;
@property(strong, nonatomic)NSString*typeQR;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *QRImageView;

@end

NS_ASSUME_NONNULL_END
