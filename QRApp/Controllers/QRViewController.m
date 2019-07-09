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


typedef NS_ENUM(NSUInteger, AVCamSetupResult) {
    AVCamSetupResultSuccess,
    AVCamSetupResultNotAutorized,
    AVCamSetupResultSessionConfigurationFailed
};

@interface QRViewController () <AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>

@property(strong, nonatomic) AVCaptureSession* session;
@property(assign, nonatomic) AVCamSetupResult setupResult;
@property(nonatomic)dispatch_queue_t sessionQueue;
@property(strong, nonatomic)AVCaptureDeviceInput* imput;
@property(strong, nonatomic)AVCaptureVideoPreviewLayer *video;
@property(strong, nonatomic)AVCaptureDevice* device;
@property(strong, nonatomic)AVCaptureMetadataOutput *output;

@property(strong, nonatomic)NSArray* request;

@end

@implementation QRViewController

#pragma mark - Lifestyle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSession];
    
    self.toolBarView.layer.cornerRadius = 10;
    self.toolBarView.layer.masksToBounds = YES;
    
    self.backButton.layer.cornerRadius = 0.5 * self.backButton.bounds.size.width;;
    self.backButton.layer.masksToBounds = YES;
    
    UISwipeGestureRecognizer* leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipe:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipe];
    
    [self actionScanQR:self.QRScanButton];
    
    self.navigationController.navigationBarHidden = YES;
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    dispatch_async(self.sessionQueue, ^{
        switch (self.setupResult) {
            case AVCamSetupResultSuccess:
            {
                //Start capture session
                [self.session startRunning];
            }
                break;
                
            default:
                break;
        }
    });
}

- (void)dealloc
{
    NSLog(@"AAAAAA");
    [self.session stopRunning];
}

#pragma mark - Actions
-(void)handleLeftSwipe:(UISwipeGestureRecognizer*)sender{
    //[self backToRoot];
    [self exitFromController];
}


- (IBAction)actionFlashOnCliked:(UIButton *)sender {
    
    if ([self.device isTorchAvailable] && [self.device isTorchModeSupported:AVCaptureTorchModeOn])
    {
        BOOL success = [self.device lockForConfiguration:nil];
        if (success)
        {
            if ([self.device isTorchActive])
            {
                [self.device setTorchMode:AVCaptureTorchModeOff];
            }
            else
            {
                [self.device setTorchMode:AVCaptureTorchModeOn];
            }
            [self.device unlockForConfiguration];
        }
    }
}

- (IBAction)actionScanQR:(UIButton *)sender {
    self.imageViewQR.hidden = NO;
    
    
//    UIImage* image = [UIImage imageNamed:@"Cam"];
//    UIImageView* camImageView = [[UIImageView alloc] initWithImage:image];
//    CGFloat width = CGRectGetWidth(self.view.bounds)*2/3;
//    camImageView.frame = CGRectMake(self.view.center.x - width/2,
//                                    self.view.center.y - width/2,
//                                    width, width);
    
    [self buttonCliked:sender];
    [self.view bringSubviewToFront:self.toolBarView];
    [self.view bringSubviewToFront:self.imageViewQR];
    [self.view bringSubviewToFront:self.backButton];
//    [self.session beginConfiguration];
//    self.outputText = nil;
//    self.output = [[AVCaptureMetadataOutput alloc] init];
//    if ([self.session canAddOutput:self.output]) {
//        [self.session addOutput:self.output];
//        [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
//        if (![self.output.metadataObjectTypes isEqualToArray:@[AVMetadataObjectTypeQRCode]]) {
//            self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
//        }
//        //self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
//    } else {
//        NSLog(@"No output");
//        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
//        [self.session commitConfiguration];
//        return;
//    }
//
//    [self.session commitConfiguration];
    
    [self.session beginConfiguration];
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    [self.session commitConfiguration];
}

- (IBAction)actionScanPDF:(UIButton *)sender {
    [self buttonCliked:sender];
    self.imageViewQR.hidden = YES;
    
    [self.session beginConfiguration];
    self.output.metadataObjectTypes = nil;
    [self.session commitConfiguration];

}

- (IBAction)actionBarcode:(UIButton *)sender{
    self.imageViewQR.hidden = YES;
    [self buttonCliked:sender];
    [self.session beginConfiguration];
    self.output.metadataObjectTypes = nil;
    [self.session commitConfiguration];
    
}

- (IBAction)scanText:(UIButton *)sender {
   // [self dismissViewControllerAnimated:NO completion:nil];
   // TextScanViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"textViewController"];
    //__weak QRViewController* weakSelf = self;
    
//    [self dismissViewControllerAnimated:NO completion:^{
////        [weakSelf.navigationController presentViewController:vc animated:NO completion:^{
////            NSLog(@"END");
////        }];
//    }];
   // [self presentViewController:vc animated:YES completion:nil];
    TextScanViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"textViewController"];
    //[self presentViewController:vc animated:NO completion:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)actionExit:(UIButton *)sender {
    [self exitFromController];
}


#pragma mark - Methods
-(void)exitFromController{
    
    CATransition *transition = [[CATransition alloc] init];
    transition.duration = 0.5;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.view.window.layer addAnimation:transition forKey:kCATransition];
    [self.session stopRunning];
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
}


-(void)initSession{
    self.session = [[AVCaptureSession alloc] init];
    
    //Preview Layer
    self.video = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.video.frame = self.view.bounds;
    self.video.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.video];
    
    
    self.sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        case AVAuthorizationStatusAuthorized:{
            break;
        }
        case AVAuthorizationStatusNotDetermined:{
            dispatch_suspend(self.sessionQueue);
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (!granted) {
                    self.setupResult = AVCamSetupResultNotAutorized;
                }
                dispatch_resume(self.sessionQueue);
            }];
            break;
        }
        default:
            self.setupResult = AVCamSetupResultNotAutorized;
            break;
    }
    
    dispatch_async(self.sessionQueue, ^{
        [self configureSession];
    });
    
}

-(void)configureSession{
    if (self.setupResult !=AVCamSetupResultSuccess) {
        return;
    }
    NSError* error = nil;
    [self.session beginConfiguration];
    
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //Imput
    if(!self.device){
        self.device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        if (!self.device) {
            self.device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
        }
    }
    AVCaptureDeviceInput* videoImput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    if (!videoImput) {
        NSLog(@"Imput errror - %@", [error localizedDescription]);
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.session commitConfiguration];
        return;
    } else if ([self.session canAddInput:videoImput]){
        [self.session addInput:videoImput];
        self.imput =videoImput;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
            if (statusBarOrientation != UIInterfaceOrientationUnknown) {
                initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
            }
            self.video.connection.videoOrientation = initialVideoOrientation;
        });
        
    } else {
        NSLog(@"No imput");
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.session commitConfiguration];
        return;
    }
    
    //Output
    self.output = [[AVCaptureMetadataOutput alloc] init];
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
        [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    } else {
        NSLog(@"No output");
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.session commitConfiguration];
        return;
    }
    
    [self.session commitConfiguration];
}


-(void)addOutput{
    self.output = [[AVCaptureMetadataOutput alloc] init];
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
        [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    } else {
        NSLog(@"No output");
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.session commitConfiguration];
        return;
    }
    [self.session commitConfiguration];
}






#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects != nil && metadataObjects.count != 0) {
        
        if ([[metadataObjects objectAtIndex:0] isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            AVMetadataMachineReadableCodeObject* object = [metadataObjects objectAtIndex:0];
            if (object.type == AVMetadataObjectTypeQRCode) {
                
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

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
//    if ([segue.identifier isEqualToString:@"fromQRtoText"]) {
//        UITabBarController* vc = segue.destinationViewController;
//        [self.session stopRunning];
//        __weak UIViewController* weakSelf = self;
//        [self dismissViewControllerAnimated:NO completion:^{
//            [weakSelf presentViewController:vc animated:YES completion:nil];
//        }];
//
 //   }
    //    if ([segue.identifier isEqualToString:@"sad"]) {
    //
    //    }
    if ([segue.identifier isEqualToString:@"fromQRtoText"]) {
//        UIWindow* array = [[[UIApplication sharedApplication] windows] firstObject];
//        UIViewController* vc = array.rootViewController;
//        [vc presentViewController:segue.destinationViewController animated:YES completion:nil];
        //[self dismissViewControllerAnimated:NO completion:nil];
        
       // NSLog(@"%@", array);
//            [self.session stopRunning];
//            [self dismissViewControllerAnimated:YES completion:nil];
        
//            TextScanViewController* vc = segue.destinationViewController;
//            __weak QRViewController* weakSelf = self;
////            [[UIApplication sharedApplication] delegate]
//            [self dismissViewControllerAnimated:NO completion:^{
//                [weakSelf presentViewController:vc animated:NO completion:^{
//                    NSLog(@"END");
//                }];
//            }];
        //UIViewController* main = [[[UIApplication sharedApplication] windows] firstObject].rootViewController;
        
//           TextScanViewController* vc = segue.destinationViewController;
//            __weak QRViewController* weakSelf = self;
//            [self presentViewController:vc animated:NO completion:^{
//                [weakSelf dismissViewControllerAnimated:NO completion:nil];
//            }];
       }
}

@end
