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




@property (weak, nonatomic) IBOutlet UIButton *addIconButton;
@property (weak, nonatomic) IBOutlet UIButton *makePhotoButton;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *QRImageView;

@property (weak, nonatomic) IBOutlet UILabel *RInfoLable;
@property (weak, nonatomic) IBOutlet UILabel *GInfoLable;
@property (weak, nonatomic) IBOutlet UILabel *BInfoLable;
@property (weak, nonatomic) IBOutlet UITextField *rTextField;
@property (weak, nonatomic) IBOutlet UITextField *gTextField;
@property (weak, nonatomic) IBOutlet UITextField *bTextField;
@property (weak, nonatomic) IBOutlet UISlider *redComponentSlider;
@property (weak, nonatomic) IBOutlet UISlider *greenComponentSlider;
@property (weak, nonatomic) IBOutlet UISlider *blueComponentSlider;

@property (weak, nonatomic) IBOutlet UILabel *frontRInfoLable;
@property (weak, nonatomic) IBOutlet UILabel *frontGInfoLable;
@property (weak, nonatomic) IBOutlet UILabel *frontBInfoLable;
@property (weak, nonatomic) IBOutlet UITextField *frontrTextField;
@property (weak, nonatomic) IBOutlet UITextField *frontgTextField;
@property (weak, nonatomic) IBOutlet UITextField *frontbTextField;
@property (weak, nonatomic) IBOutlet UISlider *frontRedComponentSlider;
@property (weak, nonatomic) IBOutlet UISlider *frontGreenComponentSlider;
@property (weak, nonatomic) IBOutlet UISlider *frontBlueComponentSlider;

@property (weak, nonatomic) IBOutlet UITextField *hexBackTextField;
@property (weak, nonatomic) IBOutlet UITextField *hexFrontTextField;


@property (strong, nonatomic) IBOutletCollection(UISlider) NSArray *backGroundSliders;
@property (weak, nonatomic) IBOutlet UISegmentedControl* colorSchemeControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl* frontColorSchemeControl;

- (IBAction)actionSlider:(UISlider *)sender;
- (IBAction)actionChangeColorScheme:(UISegmentedControl *)sender;

- (IBAction)actionRollUP:(UIButton *)sender;

- (IBAction)actionRollFrontPanel:(UIButton *)sender;

- (IBAction)actionAddLogo:(UIButton *)sender;

- (IBAction)actionTakePhoto:(UIButton *)sender;
@end

NS_ASSUME_NONNULL_END
