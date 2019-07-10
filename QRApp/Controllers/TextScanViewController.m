//
//  TextScanViewController.m
//  QRApp
//
//  Created by Сергей Семин on 06/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "TextScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Vision/Vision.h>
#import "QRViewController.h"

typedef NS_ENUM(NSUInteger, AVCamSetupResult) {
    AVCamSetupResultSuccess,
    AVCamSetupResultNotAutorized,
    AVCamSetupResultSessionConfigurationFailed
};

@interface TextScanViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property(strong, nonatomic) AVCaptureSession* session;
@property(assign, nonatomic) AVCamSetupResult setupResult;
@property(nonatomic)dispatch_queue_t sessionQueue;
@property(strong, nonatomic)AVCaptureDeviceInput* imput;

@property(strong, nonatomic)AVCaptureVideoPreviewLayer *video;
@property(strong, nonatomic)AVCaptureDevice* device;
@property(strong, nonatomic)AVCaptureVideoDataOutput *outputText;


@property(strong, nonatomic)NSArray* request;

@end

@implementation TextScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.settingsView.layer.cornerRadius = 10;
    self.settingsView.layer.masksToBounds = YES;
    
    self.textScanButton.layer.cornerRadius = 10;
    self.textScanButton.layer.masksToBounds = YES;
    
    self.exitButton.layer.cornerRadius = 10;
    self.exitButton.layer.masksToBounds = YES;
    
    self.imageView.backgroundColor = [UIColor clearColor];
    self.session = [[AVCaptureSession alloc] init];
    
    [self initSession];
    [self detectText];
    
    UISwipeGestureRecognizer* leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipe:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipe];
    
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
    //[self.view bringSubviewToFront:self.imageView];
    CGFloat width = CGRectGetHeight(self.view.bounds);
    self.bottomConstrain.constant = (width - CGRectGetHeight(self.settingsView.bounds) - 20);

    [UIView animateWithDuration:1 animations:^{
        self.textScanButton.hidden = NO;
        self.exitButton.hidden = NO;
        [self.view layoutIfNeeded];
    }];

}

- (void)dealloc
{
    NSLog(@"AAAAAA");
    [self.session stopRunning];
}

- (void)viewDidLayoutSubviews{

    self.video.frame = self.imageView.bounds;
}

#pragma mark - VideoSetting

-(void)initSession{
    //self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;


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
    
  //  dispatch_async(self.sessionQueue, ^{
        [self configureSession];
   // });
    
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
        
    } else {
        NSLog(@"No imput");
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.session commitConfiguration];
        return;
    }
    

    
    self.outputText = [[AVCaptureVideoDataOutput alloc] init];
    if ([self.session canAddOutput:self.outputText]) {
        [self.session addOutput:self.outputText];
        [self.outputText setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        
    } else {
        NSLog(@"No output");
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.session commitConfiguration];
        return;
    }
    AVCaptureVideoPreviewLayer *imageLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    //imageLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    imageLayer.frame = self.imageView.bounds;
    [self.imageView.layer addSublayer:imageLayer];
    self.video = imageLayer;
    
    [self.session commitConfiguration];

}






#pragma mark - detectig text

-(void)detectText{
    VNDetectTextRectanglesRequest* request = [[VNDetectTextRectanglesRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        
        if ([request.results isEqual:nil]) {
            return;
        }
        if (error) {
            NSLog(@"error %@", [error localizedDescription]);
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{

            self.imageView.layer.sublayers = nil;
            [self.imageView.layer addSublayer:self.video];
            
            for (VNTextObservation* region in request.results) {
                if ([region isEqual:nil]) {
                    continue;
                }

               [self higthlightWord:region];
            }
        });
        
    }];
    
    request.reportCharacterBoxes = YES;
    self.request = @[request];
}

-(void)higthlightWord:(VNTextObservation*)box{
    if ([box.characterBoxes isEqual:nil]) {
        return;
    }
    
    CGFloat maxX = 999999.0;
    CGFloat minX = 0.0;
    CGFloat maxY = 999999.0;
    CGFloat minY = 0;
    
    for (VNRectangleObservation* cha in box.characterBoxes) {
        
        if (cha.bottomLeft.x < maxX) {
            maxX = cha.bottomLeft.x;
        }
        if (cha.bottomRight.x > minX) {
            minX = cha.bottomRight.x;
        }
        if (cha.bottomRight.y < maxY) {
            maxY = cha.bottomRight.y;
        }
        if (cha.topRight.y > minY) {
            minY = cha.topRight.y;
        }
        
    }

    
    const NSInteger xCord = maxX * CGRectGetWidth(self.view.frame);
    const NSInteger yCord = (1 - minY) * self.view.frame.size.height;
    const NSInteger width = (minX - maxX) * CGRectGetWidth(self.view.frame);
    const NSInteger height = (minY - maxY) * self.view.frame.size.height;
    
    CALayer* outline = [[CALayer alloc] init];
    outline.frame = CGRectMake(xCord, yCord, width, height);
    outline.borderWidth = 1.0f;
    outline.borderColor = [UIColor redColor].CGColor;
   // NSLog(@"%@", box.)
    [self.imageView.layer addSublayer:outline];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    if (!CMSampleBufferGetImageBuffer(sampleBuffer)) {
        return;
    }
    
    id dict = nil;
    
    CFTypeRef ref = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil);
    if (ref) {
        dict = VNImageOptionCameraIntrinsics;
    }
    VNImageRequestHandler* requestHadler = [[VNImageRequestHandler alloc] initWithCVPixelBuffer:CMSampleBufferGetImageBuffer(sampleBuffer) orientation:6 options:dict];
    
    @try {
    
        [requestHadler performRequests:self.request error:nil];
        
    }
    @catch (NSException *exception) {
        NSLog(@"AAA - %@", exception.reason);
    }
    
}

#pragma mark - Orientation
- (BOOL)shouldAutorotate {
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    return orientation == UIInterfaceOrientationPortrait ? NO : YES;
}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark - Actions
- (IBAction)actionExit:(UIButton *)sender {
    CATransition *transition = [[CATransition alloc] init];
    transition.duration = 0.3;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.view.window.layer addAnimation:transition forKey:kCATransition];
    self.navigationController.navigationBarHidden = NO;
    [self.tabBarController.tabBar setHidden:NO];
    [self.session stopRunning];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)backToQR:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)flashONorOFF:(UIButton *)sender {
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

- (IBAction)actionScan:(UIButton *)sender {
     NSLog(@"actionScan:");
}

-(void)handleLeftSwipe:(UISwipeGestureRecognizer*)sender{
    CATransition *transition = [[CATransition alloc] init];
    transition.duration = 0.3;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.view.window.layer addAnimation:transition forKey:kCATransition];
    self.navigationController.navigationBarHidden = NO;
    [self.tabBarController.tabBar setHidden:NO];
    [self.session stopRunning];
    [self.navigationController popToRootViewControllerAnimated:YES];

}

@end
