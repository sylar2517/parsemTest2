//
//  QRFromImageTVC.h
//  QRApp
//
//  Created by Сергей Семин on 01/08/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QRFromImageTVC : UITableViewController

@property(strong, nonatomic)NSString*titleText;
@property(strong, nonatomic)NSString*typeQR;
@property(strong, nonatomic)UIImage*transferImage;
@property(assign, nonatomic)BOOL background;

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
@property (weak, nonatomic) IBOutlet UITextField *hexBackTextField;

@property (strong, nonatomic) IBOutletCollection(UISlider) NSArray *backGroundSliders;
@property (weak, nonatomic) IBOutlet UISegmentedControl* colorSchemeControl;

- (IBAction)actionSlider:(UISlider *)sender;
- (IBAction)actionChangeColorScheme:(UISegmentedControl *)sender;


@end

NS_ASSUME_NONNULL_END
