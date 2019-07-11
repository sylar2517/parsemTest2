//
//  ViewController.m
//  QRApp
//
//  Created by Сергей Семин on 24/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "QRViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "PopUpForCameraOrGallery.h"
#import "ResultViewController.h"
#import "TextScanViewController.h"
#import "MainSession.h"

@interface QRViewController () <AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>

@property(strong, nonatomic) NSArray* request;
@property(assign, nonatomic) BOOL haveResult;

@end

@implementation QRViewController

#pragma mark - Lifestyle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[[MainSession sharedSession] initSessionForView:self.view andMetadataObjectsDelegate:self];
//    [MainSession sharedSession].imput = nil;
//    [MainSession sharedSession].output = nil;
//    [MainSession sharedSession].outputText = nil;
    [[MainSession sharedSession] removeInput:[MainSession sharedSession].imput];
    [[MainSession sharedSession] removeOutput:[MainSession sharedSession].output];
    [[MainSession sharedSession] removeOutput:[MainSession sharedSession].outputText];
    [[MainSession sharedSession] initSessionForView:self.view forQRorText:YES];
    [[MainSession sharedSession] addOutPutForQR:self];
    //custom view editing
    self.toolBarView.layer.cornerRadius = 10;
    self.toolBarView.layer.masksToBounds = YES;
    
    self.backButton.layer.cornerRadius = 0.5 * self.backButton.bounds.size.width;;
    self.backButton.layer.masksToBounds = YES;
    
    self.snapButtonView.layer.cornerRadius = 0.5 * self.snapButtonView.bounds.size.width;;
    self.snapButtonView.layer.masksToBounds = YES;
    
    self.snapButton.layer.cornerRadius = 0.5 * self.snapButton.bounds.size.width;;
    self.snapButton.layer.masksToBounds = YES;
    
    self.conterView.layer.cornerRadius = 0.5 * self.conterView.bounds.size.width;;
    self.conterView.layer.masksToBounds = YES;
    
    self.navigationController.navigationBarHidden = YES;
    [self.tabBarController.tabBar setHidden:YES];
    
    
    
    //add exit
    UISwipeGestureRecognizer* leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipe:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipe];
    
    //go to Scan
    
    [self actionScanQR:self.QRScanButton];
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //Start scan
    
//    if ([[MainSession sharedSession] isRunning]) {
//        [[MainSession sharedSession] reloadSessionForView:self.view andMetadataObjectsDelegate:self];
//        [self actionScanQR:self.QRScanButton];
//    } else {
        dispatch_async([MainSession sharedSession].sessionQueue, ^{
            switch ([MainSession sharedSession].setupResult) {
                case AVCamSetupResultSuccess:
                {
                    [[MainSession sharedSession] startRunning];
                }
                    break;
                    
                default:
                    break;
            }
        });
    //}

    
    self.haveResult = YES;
}

- (void)dealloc
{
    [[MainSession sharedSession] stopRunning];
    //[[MainSession sharedSessionForScanText] stopRunning];
}

#pragma mark - Actions
-(void)handleLeftSwipe:(UISwipeGestureRecognizer*)sender{
    [self exitFromController];
}


- (IBAction)actionFlashOnCliked:(UIButton *)sender {
     AVCaptureDevice *flashLight = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([flashLight isTorchAvailable] && [flashLight isTorchModeSupported:AVCaptureTorchModeOn])
    {
        BOOL success = [flashLight lockForConfiguration:nil];
        if (success)
        {
            if ([flashLight isTorchActive]) {
                [flashLight setTorchMode:AVCaptureTorchModeOff];
            } else {
                [flashLight setTorchMode:AVCaptureTorchModeOn];
            }
            [flashLight unlockForConfiguration];
        }
    }
}


- (IBAction)actionScanQR:(UIButton *)sender {
    self.imageViewQR.hidden = NO;
    
    [self buttonCliked:sender];
    [self.view bringSubviewToFront:self.toolBarView];
    [self.view bringSubviewToFront:self.imageViewQR];
    [self.view bringSubviewToFront:self.backButton];
    
    [[MainSession sharedSession] beginConfiguration];
    [MainSession sharedSession].output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    [[MainSession sharedSession] commitConfiguration];
}

- (IBAction)actionScanPDF:(UIButton *)sender {
    [self buttonCliked:sender];
    self.imageViewQR.hidden = YES;
    
    
    [UIView animateWithDuration:0.25 animations:^{
        self.snapButton.hidden = self.snapButtonView.hidden = NO;
        [self.view bringSubviewToFront:self.snapButton];
        [self.view bringSubviewToFront:self.snapButtonView];
    }];
}

- (IBAction)actionBarcode:(UIButton *)sender{
    [self buttonCliked:sender];
}

- (IBAction)scanText:(UIButton *)sender {
    
    TextScanViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"textViewController"];
    [self.navigationController pushViewController:vc animated:YES];
    
    
}

- (IBAction)actionExit:(UIButton *)sender {
    [self exitFromController];
}

- (IBAction)actionMakePhoto:(UIButton *)sender {
   // [self buttonCliked:sender];
    UIView* shot = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                            0,
                                                            CGRectGetWidth(self.view.bounds),
                                                            CGRectGetHeight(self.view.bounds))];
    self.conterButton.hidden = NO;
    self.conterView.hidden = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
        shot.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        [self.view addSubview:shot];
        
    } completion:^(BOOL finished) {
        [shot removeFromSuperview];
        [self.view bringSubviewToFront:self.conterButton];
        [self.view bringSubviewToFront:self.conterView];
    }];
    [self.conterButton setTitle:@"1" forState:(UIControlStateNormal)];
    
    [[MainSession sharedSession] beginConfiguration];
    //[MainSession sharedSession].output.setSa
    [[MainSession sharedSession] commitConfiguration];
    //[[MainSession sharedSession] re]
//    [MainSession sharedSession].ou = [[AVCaptureVideoDataOutput alloc] init];
//    if ([[MainSession sharedSession].outputText canAddOutput:[MainSession sharedSessionForScanText].outputText]) {
//        [[MainSession sharedSessionForScanText] addOutput:[MainSession sharedSessionForScanText].outputText];
//        [[MainSession sharedSessionForScanText].outputText setSampleBufferDelegate:sampleBufferDelegate queue:dispatch_get_main_queue()];
//
//    } else {
//        NSLog(@"No output");
//        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
//        [[MainSession sharedSessionForScanText] commitConfiguration];
//        return;
//    }
}

- (IBAction)actionWatchPDF:(UIButton *)sender {
    NSLog(@"AAAAAA");
}



#pragma mark - Methods
-(void)exitFromController{
    
    CATransition *transition = [[CATransition alloc] init];
    transition.duration = 0.5;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.view.window.layer addAnimation:transition forKey:kCATransition];
    [[MainSession sharedSession] stopRunning];
    //[[MainSession sharedSessionForScanText] stopRunning];
    [self.navigationController popToRootViewControllerAnimated:YES];
    self.navigationController.navigationBarHidden = NO;
    [self.tabBarController.tabBar setHidden:NO];
    
}
-(void)buttonCliked:(UIButton*)sender{
    for (UIButton* but in self.buttons) {
        if ([but isEqual:sender]) {
            [UIView animateWithDuration:0.25 animations:^{
                but.backgroundColor = [UIColor whiteColor];
            }];
        } else {
            but.backgroundColor = [UIColor clearColor];
        }
    }
    
    void (^noQR)(void) = ^{
        [[MainSession sharedSession] beginConfiguration];
        [MainSession sharedSession].output.metadataObjectTypes = nil;
        [[MainSession sharedSession] commitConfiguration];
    };
    
    if (sender.tag != 0) {
        self.imageViewQR.hidden = YES;
        noQR();
    } else if (sender.tag != 1){
        self.snapButton.hidden = self.snapButtonView.hidden =self.conterView.hidden = YES;
        noQR();
    } else {
        self.imageViewQR.hidden = self.snapButton.hidden = self.snapButtonView.hidden = YES;
        noQR();
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects != nil && metadataObjects.count != 0) {
        
        if ([[metadataObjects objectAtIndex:0] isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            AVMetadataMachineReadableCodeObject* object = [metadataObjects objectAtIndex:0];
            if (object.type == AVMetadataObjectTypeQRCode && self.haveResult) {
                
                self.haveResult = NO;
                ResultViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"resultVC"];
                vc.result = object.stringValue;
                vc.fromCamera = YES;
                [self presentViewController:vc animated:YES completion:nil];
                
            }
        }
    }
}



#pragma mark - Orientation
- (BOOL)shouldAutorotate {
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    return orientation == UIInterfaceOrientationPortrait ? NO : YES;
}

//#pragma mark - Navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//
//    if ([segue.identifier isEqualToString:@"fromQRtoText"]) {
//
//    }
//}

@end
