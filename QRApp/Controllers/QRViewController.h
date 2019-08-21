//
//  ViewController.h
//  QRApp
//
//  Created by Сергей Семин on 24/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ScrollViewController;
@class QRViewController;
@protocol QRViewControllerDelegate
- (void)pushResultVC:(NSString*)string;
@end

@interface QRViewController : UIViewController
@property (weak, nonatomic) ScrollViewController* parent;

@property (nonatomic, weak) id <QRViewControllerDelegate> delegate;


@property (weak, nonatomic) IBOutlet UIView *toolBarView;
@property (weak, nonatomic) IBOutlet UIButton *QRScanButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewQR;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *buttons;
@property (weak, nonatomic) IBOutlet UIView *snapButtonView;
@property (weak, nonatomic) IBOutlet UIButton *snapButton;
@property (weak, nonatomic) IBOutlet UIView *conterView;
@property (weak, nonatomic) IBOutlet UIButton *conterButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstrain;
@property (weak, nonatomic) IBOutlet UIButton *textScanButton;
//@property (weak, nonatomic) IBOutlet UIButton *exitButton;


- (IBAction)actionFlashOnCliked:(UIButton *)sender;
- (IBAction)actionScanQR:(UIButton *)sender;
- (IBAction)actionScanPDF:(UIButton *)sender;

- (IBAction)actionBarcode:(UIButton *)sender;
- (IBAction)scanText:(UIButton *)sender;
- (IBAction)actionMakePhoto:(UIButton *)sender;
- (IBAction)actionWatchPDF:(UIButton *)sender;



@end

