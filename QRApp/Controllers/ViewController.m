//
//  ViewController.m
//  QRApp
//
//  Created by Сергей Семин on 24/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PopUpForCameraOrGallery.h"
#import "ResultViewController.h"

typedef NS_ENUM(NSUInteger, AVCamSetupResult) {
    AVCamSetupResultSuccess,
    AVCamSetupResultNotAutorized,
    AVCamSetupResultSessionConfigurationFailed
};

@interface ViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property(strong, nonatomic) AVCaptureSession* session;
@property(assign, nonatomic) AVCamSetupResult setupResult;
@property(nonatomic)dispatch_queue_t sessionQueue;
@property(strong, nonatomic)AVCaptureDeviceInput* imput;
@property(strong, nonatomic)AVCaptureVideoPreviewLayer *video;
@property(strong, nonatomic)AVCaptureDevice* device;
@end

@implementation ViewController
#pragma mark - Lifestyle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSession];
    
    UIImage* image = [UIImage imageNamed:@"Cam"];
    UIImageView* camImageView = [[UIImageView alloc] initWithImage:image];
    CGFloat width = CGRectGetWidth(self.view.bounds)*2/3;
    camImageView.frame = CGRectMake(self.view.center.x - width/2,
                                    self.view.center.y - width/2,
                                    width, width);
    [self.view addSubview:camImageView];
    
    self.toolBarView.layer.cornerRadius = 10;
    self.toolBarView.layer.masksToBounds = YES;
    [self.view bringSubviewToFront:self.toolBarView];
    
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
}

- (void)dealloc
{
    [self.session stopRunning];
}



#pragma mark - Methods
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
    [self.session commitConfiguration];
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
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    if ([self.session canAddOutput:output]) {
        [self.session addOutput:output];
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    } else {
        NSLog(@"No output");
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.session commitConfiguration];
        return;
    }
    [self.session commitConfiguration];
    
}

#pragma mark - Actions
-(void)handleLeftSwipe:(UISwipeGestureRecognizer*)sender{
    [self dismissViewControllerAnimated:NO completion:nil];
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

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects != nil && metadataObjects.count != 0) {
        
        if ([[metadataObjects objectAtIndex:0] isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            AVMetadataMachineReadableCodeObject* object = [metadataObjects objectAtIndex:0];
            if (object.type == AVMetadataObjectTypeQRCode) {
//                UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"TADA" message:object.stringValue preferredStyle:(UIAlertControllerStyleAlert)];
//                UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Отмена" style:(UIAlertActionStyleCancel) handler:nil];
//                [ac addAction:cancel];
//                [self presentViewController:ac animated:YES completion:nil];
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

@end
