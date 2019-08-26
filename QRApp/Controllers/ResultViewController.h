//
//  ResultViewController.h
//  QRApp
//
//  Created by Сергей Семин on 27/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class HistoryPost, QRPost;
@interface ResultViewController : UIViewController

@property(strong, nonatomic)NSString* result;
@property(strong, nonatomic)HistoryPost* post;
@property(assign, nonatomic)BOOL fromCamera;
@property(assign, nonatomic)BOOL isBarcode;
@property(strong, nonatomic)QRPost* postQR;
@property(strong, nonatomic)NSString * AVMetadataObjectType;

//
//
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *originHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIImageView *resultImageView;
@property (weak, nonatomic) IBOutlet UITextView *resultTextImageView;
@property (weak, nonatomic) IBOutlet UIButton *openInBrowser;
@property (weak, nonatomic) IBOutlet UIButton *copingButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *exportButton;
@property (weak, nonatomic) IBOutlet UIButton *rollUpButton;


@property (weak, nonatomic) IBOutlet UIView *parentView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayoutConstraint;



- (IBAction)actionBack:(UIButton *)sender;
- (IBAction)actionCopy:(UIButton *)sender;
- (IBAction)actionOpenInBrowser:(id)sender;
- (IBAction)actionSave:(UIButton *)sender;
- (IBAction)actionExport:(UIButton *)sender;



@end

NS_ASSUME_NONNULL_END
