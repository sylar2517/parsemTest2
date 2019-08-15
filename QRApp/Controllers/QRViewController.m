//
//  ViewController.m
//  QRApp
//
//  Created by Сергей Семин on 24/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "QRViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Vision/Vision.h>

#import "WebViewController.h"
#import "PopUpForCameraOrGallery.h"
#import "ResultViewController.h"
#import <AudioToolbox/AudioToolbox.h>


#import "ScrollViewController.h"


typedef NS_ENUM(NSUInteger, AVCamSetupResult) {
    AVCamSetupResultSuccess,
    AVCamSetupResultNotAutorized,
    AVCamSetupResultSessionConfigurationFailed
};


@interface QRViewController () <AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate, ScrollViewControllerDelegate, AVCapturePhotoCaptureDelegate>

@property(strong, nonatomic)UIView* qrView;
@property(strong, nonatomic)UILabel* qrLabel;

@property(strong, nonatomic) NSArray* request;
@property(assign, nonatomic) BOOL haveResult;
@property(assign, nonatomic) BOOL takePhoto;
@property(assign, nonatomic) NSInteger buttonPressed;
@property(strong, nonatomic) NSMutableArray* tempForPhoto;


@property(strong, nonatomic) AVCaptureSession* session;
@property(assign, nonatomic) AVCamSetupResult setupResult;
@property(nonatomic)dispatch_queue_t sessionQueue;
@property(strong, nonatomic)AVCaptureDeviceInput* imput;
@property(strong, nonatomic)AVCaptureVideoPreviewLayer *video;
@property(strong, nonatomic)AVCaptureDevice* device;
@property(strong, nonatomic)AVCaptureMetadataOutput *output;
@property(strong, nonatomic)AVCaptureVideoDataOutput *outputText;
@property(strong, nonatomic)AVCapturePhotoOutput *outputPhoto;
@property(assign, nonatomic)BOOL isScaningText;


@end

@implementation QRViewController

#pragma mark - Lifestyle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.buttonPressed = 0;
    self.tempForPhoto = [NSMutableArray array];
    
    self.session = [[AVCaptureSession alloc] init];
    [self initSessionForQR:YES];
    
    //custom view editing
    self.toolBarView.layer.cornerRadius = 10;
    self.toolBarView.layer.masksToBounds = YES;
    
    self.textScanButton.layer.cornerRadius = 10;
    self.textScanButton.layer.masksToBounds = YES;
    
    self.exitButton.layer.cornerRadius = 10;
    self.exitButton.layer.masksToBounds = YES;
    
    self.conterView.layer.cornerRadius = 0.5 * self.conterView.bounds.size.width;;
    self.conterView.layer.masksToBounds = YES;
    
    self.snapButtonView.layer.cornerRadius = 0.5 * self.snapButtonView.bounds.size.width;;
    self.snapButtonView.layer.masksToBounds = YES;
    
    self.snapButton.layer.cornerRadius = 0.5 * self.snapButton.bounds.size.width;;
    self.snapButton.layer.masksToBounds = YES;
    
    //go to Scan
    
    [self actionScanQR:self.QRScanButton];
    
    //add notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appMovedToForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appMovedToBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];

    self.parent.delegate = self;
    self.haveResult = YES;
    
    self.qrView = [[UIView alloc] init];
    self.qrLabel = [[UILabel alloc] init];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //Start scan

    dispatch_async(self.sessionQueue, ^{
        switch (self.setupResult) {
            case AVCamSetupResultSuccess:
            {
                [self.session startRunning];
            }
                break;

            default:
                break;
        }
    });
    
    if (self.tempForPhoto.count > 1) {
        [self.tempForPhoto removeAllObjects];
    }
    
    self.conterButton.hidden = YES;
    self.conterView.hidden = YES;
    
    
    [self.qrView removeFromSuperview];
    self.qrView.frame = CGRectZero;
    self.qrLabel.text = nil;
}


- (void)dealloc
{
    self.imageView = nil;
    [self.session stopRunning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.tempForPhoto.count > 1) {
        [self.tempForPhoto removeAllObjects];
    }
}
- (void)viewDidLayoutSubviews{

    [super viewDidLayoutSubviews];

//    NSLog(@"%@", self.imageView.layer.sublayers);
    if (self.imageView.layer.sublayers.count > 1) {
        for (CALayer *layer in [self.imageView.layer.sublayers copy]) {
            if (![layer isKindOfClass:[AVCaptureVideoPreviewLayer class]]) {
                [layer removeFromSuperlayer];
            }
        }
    }
//    NSLog(@"2 - %@", self.imageView.layer.sublayers);
}


#pragma mark - touches
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//
//    CGPoint point = [[touches anyObject] locationInView:self.view];
////    float newX = point.x / self.view.frame.size.width;
////    float newY = point.y / self.view.frame.size.height;
//
//
//    [self.device lockForConfiguration:nil];
//    [self.device setFocusPointOfInterest:point];
//    [self.device setFocusMode:(AVCaptureFocusModeAutoFocus)];
//    [self.device setExposurePointOfInterest:point];
//    [self.device setExposureMode:(AVCaptureExposureModeContinuousAutoExposure)];
//
//    [self.device unlockForConfiguration];
//
////    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
////    view.backgroundColor = UIColor.redColor;
////    view.center = point;
////    [self.view addSubview:view];
////    [self.view bringSubviewToFront:view];
//}
#pragma mark - ScrollViewControllerDelegate

- (void) changeScreen:(BOOL)stopSession{
    
    if (stopSession) {
        
        if (![self.session isRunning]) {

        } else {
            [self.session stopRunning];
        }
        self.haveResult = NO;
        
    } else {
        [self.session startRunning];
        self.haveResult = YES;
    }
}

#pragma mark - SessionSettings

-(void)highlightBordersQR{
    
    self.qrView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.qrView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.6];
    self.qrView.layer.borderWidth = 2;
    self.qrView.layer.cornerRadius = 10;
    self.qrView.layer.masksToBounds = YES;
    
    [self.view addSubview:self.qrView];
    [self.view bringSubviewToFront:self.qrView];
    
    self.qrLabel.frame = self.qrView.frame;
   
    self.qrLabel.numberOfLines = 10;
    self.qrLabel.adjustsFontSizeToFitWidth = YES;
    self.qrLabel.lineBreakMode = NSLineBreakByClipping;
    self.qrLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.qrLabel setTextColor:[UIColor whiteColor]];
    [self.qrLabel setBackgroundColor:[UIColor clearColor]];
    
    [self.view addSubview:self.qrLabel];
    [self.view bringSubviewToFront:self.qrLabel];
}

-(void)initSessionForQR:(BOOL) boolVal{
    
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    
    if (boolVal) {
        AVCaptureVideoPreviewLayer* layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        layer.frame = self.view.bounds;
        [self.view.layer addSublayer:layer];
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.video = layer;
    }
    

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
        [self addImputForQR:boolVal];
    });
}

-(void)addImputForQR:(BOOL)boolVal{
    if (self.setupResult !=AVCamSetupResultSuccess) {
        return;
    }
    NSError* error = nil;
    
    [self.session beginConfiguration];
    
    AVCaptureDevice* device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //Imput
    if(!device){
        device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        if (!device) {
            device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
        }
    }
    self.imput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!self.imput) {
        NSLog(@"Imput errror - %@", [error localizedDescription]);
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.session commitConfiguration];
        return;
    } else if ([self.session canAddInput:self.imput]){
        [self.session addInput:self.imput];
        
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
    if (boolVal) {
        [self addOutPutForQR:self];
    } else {
        [self addOutPutForText:self];
    }
}

-(void)addOutPutForQR:(nullable id<AVCaptureMetadataOutputObjectsDelegate>)objectsDelegate{
    self.output = [[AVCaptureMetadataOutput alloc] init];
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
        [self.output setMetadataObjectsDelegate:objectsDelegate queue:dispatch_get_main_queue()];
        self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    } else {
        NSLog(@"No output");
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.session commitConfiguration];
        return;
    }
    
    [self.session commitConfiguration];
}

-(void)addOutPutForText:(nullable id<AVCaptureVideoDataOutputSampleBufferDelegate>)sampleBufferDelegate{
    
    self.outputText = [[AVCaptureVideoDataOutput alloc] init];
   
    
    if (self.isScaningText) {
        
        if ([self.session canAddOutput:self.outputText]) {
            [self.session addOutput:self.outputText];
            
            self.outputText.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]
                                                                        forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
            self.outputText.alwaysDiscardsLateVideoFrames = YES;
            [self.outputText setSampleBufferDelegate:sampleBufferDelegate queue:dispatch_get_main_queue()];
        } else {
            NSLog(@"No output");
            self.setupResult = AVCamSetupResultSessionConfigurationFailed;
            [self.session commitConfiguration];
            return;
        }

    } else {
        
        
        
        self.outputPhoto = [[AVCapturePhotoOutput alloc]init];
        if ([self.session canAddOutput:self.outputPhoto]) {
            [self.session addOutput:self.outputPhoto];
            self.outputPhoto.highResolutionCaptureEnabled = YES;

            
        } else {
            NSLog(@"No output");
            self.setupResult = AVCamSetupResultSessionConfigurationFailed;
            [self.session commitConfiguration];
            return;
        }
    }
    
    [self.session commitConfiguration];
    
}
-(void)reloadSession{
    [self.session beginConfiguration];
    [self.session removeInput:self.imput];
    [self.session removeOutput:self.output];
    [self.session removeOutput:self.outputText];
    [self.session removeOutput:self.outputPhoto];
    [self.session commitConfiguration];
}
#pragma mark - Actions
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
    [self buttonCliked:sender];
    
    if (sender.tag == self.buttonPressed) {
        return;
    }
    
    [self reloadSession];
    [self initSessionForQR:YES];
    
    [self buttonCliked:sender];
    
    self.buttonPressed = sender.tag;
    
}

- (IBAction)actionScanPDF:(UIButton *)sender {

    
    if (sender.tag == self.buttonPressed) {
        return;
    }
    
    self.isScaningText = NO;
    
    [self reloadSession];
    [self initSessionForQR:NO];
    
    [self.session beginConfiguration];
    AVCaptureVideoPreviewLayer* layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    layer.frame = self.view.bounds;
    [self.view.layer addSublayer:layer];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.video = layer;
    [self.session commitConfiguration];
    
    
    [self buttonCliked:sender];
    self.buttonPressed = sender.tag;
}

- (IBAction)actionBarcode:(UIButton *)sender{

    if (sender.tag == self.buttonPressed) {
        return;
    }
    
    [self buttonCliked:sender];
    
     self.buttonPressed = sender.tag;
}

- (IBAction)scanText:(UIButton *)sender {
    if (sender.tag == self.buttonPressed) {
        return;
    }
    
    [self buttonCliked:sender];
    self.isScaningText = YES;
    self.takePhoto = NO;
    
    
    [self reloadSession];
    
    [self detectText];
    [self initSessionForQR:NO];
    
    
    [self.session beginConfiguration];
    AVCaptureVideoPreviewLayer *imageLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    imageLayer.videoGravity = AVLayerVideoGravityResize;
    imageLayer.frame = self.imageView.bounds;
    [self.imageView.layer addSublayer:imageLayer];
    self.video = imageLayer;
    
    [self.session commitConfiguration];
    [self.view layoutIfNeeded];

    self.buttonPressed = sender.tag;
}


- (IBAction)actionMakePhoto:(UIButton *)sender {
    
    self.takePhoto = YES;
    
    self.conterView.backgroundColor = [UIColor blackColor];
    __block UIView* snap = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                            0,
                                                            CGRectGetWidth(self.view.bounds),
                                                            CGRectGetHeight(self.view.bounds))];
    self.conterButton.hidden = NO;
    self.conterView.hidden = NO;
    [self.view bringSubviewToFront:self.conterButton];
    [self.view bringSubviewToFront:self.conterView];
    
    
    AVCapturePhotoSettings* settings = [AVCapturePhotoSettings photoSettings];
    settings.flashMode = AVCaptureFlashModeOff;
//    [self.session beginConfiguration];
    [self.outputPhoto capturePhotoWithSettings:settings delegate:self];
//    [self.session commitConfiguration];
    
    
    [UIView animateWithDuration:0.25 animations:^{
        snap.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        [self.view addSubview:snap];
       
    } completion:^(BOOL finished) {
        [snap removeFromSuperview];
        snap = nil;
        
        
//        [self.outputText capture]
        
        
    }];
    
}

- (IBAction)actionWatchPDF:(UIButton *)sender {
   
    if (self.tempForPhoto && self.tempForPhoto.count > 0) {
        [self.session stopRunning];

        WebViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"webView"];
        vc.photoArray = self.tempForPhoto;
        //[self.tempForPhoto removeAllObjects];
        [self presentViewController:vc animated:YES completion:nil];
    }
}



#pragma mark - Methods

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
        [self.session beginConfiguration];
        self.output.metadataObjectTypes = nil;
        [self.session commitConfiguration];
    };
    
    if (sender.tag == 0) {
        
        
        [self allHidden];

        [UIView animateWithDuration:0.5 animations:^{
            self.imageViewQR.hidden = NO;
            [self.view layoutIfNeeded];
        }];
        
    } else if (sender.tag == 1){
        noQR();
        [self allHidden];
        self.snapButton.hidden = self.snapButtonView.hidden = NO; //self.conterView.hidden
        
        [UIView animateWithDuration:0.5 animations:^{
            self.snapButton.hidden = self.snapButtonView.hidden = NO;
            [self.view layoutIfNeeded];
        }];
        
    } else if (sender.tag == 2){
        noQR();
        [self allHidden];

        CGFloat width = CGRectGetHeight(self.view.bounds);
        self.bottomConstrain.constant = (width - CGRectGetHeight(self.toolBarView.bounds) - 20);
        
        [UIView animateWithDuration:1 animations:^{
            self.textScanButton.hidden = NO;
            self.exitButton.hidden = NO;
            [self.view layoutIfNeeded];
        }];
        
    } else if (sender.tag == 3) {
        noQR();
        [self allHidden];
        [UIView animateWithDuration:0.5 animations:^{

            [self.view layoutIfNeeded];
        }];
    }
}
-(void)allHidden{
    [self.view layoutIfNeeded];
    self.imageViewQR.hidden = YES;
    self.snapButton.hidden = self.snapButtonView.hidden =self.conterView.hidden = YES;
    self.snapButton.hidden = self.snapButtonView.hidden = YES;
    self.textScanButton.hidden = self.exitButton.hidden = YES;
    self.conterButton.hidden = YES;
    self.bottomConstrain.constant = 20;
    [self.view bringSubviewToFront:self.toolBarView];
    [self.view bringSubviewToFront:self.imageViewQR];
    [self.view bringSubviewToFront:self.snapButton];
    [self.view bringSubviewToFront:self.snapButtonView];
    [self.view bringSubviewToFront:self.conterButton];
    
    if (self.tempForPhoto.count > 1) {
        [self.tempForPhoto removeAllObjects];
    }
    
    
}
#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    if (metadataObjects.count == 0) {
        [self.qrView removeFromSuperview];
        self.qrView.frame = CGRectZero;
        self.qrLabel.text = nil;
    }
    
    if (metadataObjects != nil && metadataObjects.count != 0) {
        
        if ([[metadataObjects objectAtIndex:0] isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            AVMetadataMachineReadableCodeObject* object = [metadataObjects objectAtIndex:0];
            
            if (object.type == AVMetadataObjectTypeQRCode && self.haveResult) {
                //
                //[self.video transformedMetadataObjectForMetadataObject:object].accessibilityFrame;
//                NSLog(@"%@", [NSNumber numberWithInt:self.haveResult]);
                AVMetadataObject * obj = [self.video transformedMetadataObjectForMetadataObject:object];
                
//                self.qrView.frame = [[UIView alloc] initWithFrame:obj.bounds];
                self.qrView.frame = obj.bounds;
 
           
                if (![self.qrLabel.text isEqualToString:object.stringValue]) {
                    self.qrLabel.text = object.stringValue;
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    AudioServicesPlayAlertSound (1117);
                    [self.session stopRunning];
                    //self.haveResult = NO;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.delegate pushResultVC:object.stringValue];
                    });
                    
                }
  
            
                self.qrLabel.text = object.stringValue;
                [self highlightBordersQR];
                //self.haveResult = NO;
//                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//                AudioServicesPlayAlertSound (1117);
//                ResultViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"resultVC"];
//                vc.result = object.stringValue;
//                vc.fromCamera = YES;
//                [self presentViewController:vc animated:YES completion:nil];
                
            }
            else if ((object.type == AVMetadataObjectTypeAztecCode || object.type == AVMetadataObjectTypeDataMatrixCode)) {
 //&& self.haveResult
               // self.haveResult = NO;
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                AudioServicesPlayAlertSound (1117);

                //[NSString stringWithFormat:@"Это не QR %@", object.stringValue];
                UIAlertController* ac = [UIAlertController alertControllerWithTitle: @"Это не QR" message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];

                UIAlertAction* aa = [UIAlertAction actionWithTitle:@"Отмена" style:(UIAlertActionStyleCancel) handler:nil];
                UIAlertAction* editing = [UIAlertAction actionWithTitle: [NSString stringWithFormat:@"%@", object.stringValue] style:(UIAlertActionStyleDefault) handler:nil];


                [ac addAction:editing];
                [ac addAction:aa];

                [self presentViewController:ac animated:YES completion:nil];

            } else if ((object.type == AVMetadataObjectTypeCode128Code || object.type == AVMetadataObjectTypeEAN8Code || object.type == AVMetadataObjectTypeUPCECode || object.type == AVMetadataObjectTypeCode39Code)) {
                //&& self.haveResult
                // self.haveResult = NO;
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                AudioServicesPlayAlertSound (1117);
                
                //[NSString stringWithFormat:@"Это не QR %@", object.stringValue];
                UIAlertController* ac = [UIAlertController alertControllerWithTitle: @"Это не QR" message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
                
                UIAlertAction* aa = [UIAlertAction actionWithTitle:@"Отмена" style:(UIAlertActionStyleCancel) handler:nil];
                UIAlertAction* editing = [UIAlertAction actionWithTitle: [NSString stringWithFormat:@"%@", object.stringValue] style:(UIAlertActionStyleDefault) handler:nil];
                
                
                [ac addAction:editing];
                [ac addAction:aa];
                
                [self presentViewController:ac animated:YES completion:nil];
                
            }
        }
    }
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
            
            for (CALayer *layer in [self.imageView.layer.sublayers copy]) {
                if (![layer isKindOfClass:[AVCaptureVideoPreviewLayer class]]) {
                    [layer removeFromSuperlayer];
                }
            }

            for (VNTextObservation* region in request.results) {
                if ([region isEqual:nil]) {
                    continue;
                }

                [self higthlightWord:region];

                NSArray* boxes = region.characterBoxes;
                if (boxes) {
                    for (VNRectangleObservation* characterBox in boxes) {
                        [self higthlightLetters:characterBox];
                    }
                }
            }
        });
        
    }];
    
    request.reportCharacterBoxes = YES;
    self.request = @[request];
}

-(void)higthlightLetters:(VNRectangleObservation*)box{
    const NSInteger xCord = box.topLeft.x * self.imageView.frame.size.width;
    const NSInteger yCord = (1 - box.topLeft.y) * self.imageView.frame.size.height;
    const NSInteger width = (box.topRight.x - box.bottomLeft.x) * self.imageView.frame.size.width;
    const NSInteger height = (box.topLeft.y - box.bottomLeft.y) * self.imageView.frame.size.height;
    
    CALayer* outline = [[CALayer alloc] init];
    outline.frame = CGRectMake(xCord, yCord, width, height);
    outline.borderWidth = 1.0f;
    outline.borderColor = [UIColor lightGrayColor].CGColor;
    [self.imageView.layer addSublayer:outline];
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
    
    
    const NSInteger xCord = maxX * CGRectGetWidth(self.video.frame);
    const NSInteger yCord = (1 - minY) * CGRectGetHeight(self.video.frame);
    const NSInteger width = (minX - maxX) * CGRectGetWidth(self.video.frame);
    const NSInteger height = (minY - maxY) * CGRectGetHeight(self.video.frame);
    
    CALayer* outline = [[CALayer alloc] init];
    outline.frame = CGRectMake(xCord, yCord, width, height);
    outline.borderWidth = 2.0f;
    outline.borderColor = [UIColor darkGrayColor].CGColor;
    [self.imageView.layer addSublayer:outline];
}


#pragma mark - AVCapturePhotoCaptureDelegate
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error{
    if (error) {
        NSLog(@"error : %@", error.localizedDescription);
    }

    NSData *photoData = [photo fileDataRepresentation];
    UIImage* image = [UIImage imageWithData:photoData];
    [self.tempForPhoto addObject:image];
    [self.conterButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)self.tempForPhoto.count] forState:(UIControlStateNormal)];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    if (self.isScaningText) {
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
//    else if (self.takePhoto) {
//        self.takePhoto = NO;
//
//        UIImage* image =[self getImageFromSampleBuffer:sampleBuffer];
//        if (image) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.tempForPhoto addObject:image];
//            });
//        }
//
//    }
    
    
}
//-(UIImage*)getImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer{
//    CVImageBufferRef buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//    if (buffer) {
//        CIImage* ciImage = [CIImage imageWithCVPixelBuffer:buffer];
//        CIContext* context = [CIContext context];
//
//        CGRect imageRect = CGRectMake(0, 0, CVPixelBufferGetWidth(buffer), CVPixelBufferGetHeight(buffer));
//
//        CGImageRef image = [context createCGImage:ciImage fromRect:imageRect];
//        if (image) {
//            return [UIImage imageWithCGImage:image scale:UIScreen.mainScreen.scale orientation:(UIImageOrientationRight)];
//        }
//    }
//    return nil;
//}

#pragma mark - NSNotification
-(void)appMovedToForeground:(NSNotification*)notification{
    [self.session startRunning];
}
-(void)appMovedToBackground:(NSNotification*)notification{
    [self.session stopRunning];
}


@end
