////
////  MainSession.m
////  QRApp
////
////  Created by Сергей Семин on 11/07/2019.
////  Copyright © 2019 Сергей Семин. All rights reserved.
////
//
//#import "MainSession.h"
//@interface MainSession ()
////@property(strong, nonatomic) AVCaptureSession* session;
////@property(assign, nonatomic) AVCamSetupResult setupResult;
////@property(nonatomic)dispatch_queue_t sessionQueue;
////@property(strong, nonatomic)AVCaptureDeviceInput* imput;
////@property(strong, nonatomic)AVCaptureVideoPreviewLayer *video;
////@property(strong, nonatomic)AVCaptureDevice* device;
////@property(strong, nonatomic)AVCaptureMetadataOutput *output;
//@end
//
//@implementation MainSession
//
//
//
//+(MainSession*) sharedSession{
//    static MainSession* session = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        session = [[MainSession alloc] init];
//    });
//    return session;
//}
//
//+(MainSession*) sharedSessionForScanText{
//    static MainSession* session = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        session = [[MainSession alloc] init];
//    });
//    return session;
//}
//
//#pragma mark - Model
//-(void)initSessionForView:(UIView*)view forQRorText:(BOOL)qr{
//    
//    self.sessionPreset = AVCaptureSessionPresetPhoto;
//    
//    AVCaptureVideoPreviewLayer* layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self];
//    layer.frame = view.bounds;
//    [view.layer addSublayer:layer];
//    if (qr) {
//        layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    }
//    
//    self.sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
//    self.sessionTextQueue = dispatch_queue_create("session queue2", DISPATCH_QUEUE_SERIAL);
//    
//    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
//        case AVAuthorizationStatusAuthorized:{
//            break;
//        }
//        case AVAuthorizationStatusNotDetermined:{
//            
//             if (qr) {
//            dispatch_suspend(self.sessionQueue);
//            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
//                if (!granted) {
//                    self.setupResult = AVCamSetupResultNotAutorized;
//                }
//                dispatch_resume(self.sessionQueue);
//            }];
//                        }
//                        else  {
//                            dispatch_suspend(self.sessionTextQueue);
//                            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
//                                if (!granted) {
//                                    self.setupResult = AVCamSetupResultNotAutorized;
//                                }
//                                dispatch_resume(self.sessionTextQueue);
//                            }];
//                        }
//            break;
//        }
//        default:
//            self.setupResult = AVCamSetupResultNotAutorized;
//            break;
//    }
//    //    if (qr) {
//    //        dispatch_async(self.sessionQueue, ^{
//    //            //[self configureSessionAndMetadataObjectsDelegate:objectsDelegate];
//    //        });
//    //    }
//    //    else {
//    //        //просто вызвать
//    //    }
//    //dispatch_async(self.sessionQueue, ^{
//        [self addImput];
//    //});
//}
//-(void)addImput{
//    if (self.setupResult !=AVCamSetupResultSuccess) {
//        return;
//    }
//    NSError* error = nil;
//    
//    [self beginConfiguration];
//    
//    AVCaptureDevice* device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//    
//    //Imput
//    if(!device){
//        device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
//        if (!device) {
//            device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
//        }
//    }
//    self.imput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
//    if (!self.imput) {
//        NSLog(@"Imput errror - %@", [error localizedDescription]);
//        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
//        [self commitConfiguration];
//        return;
//    } else if ([self canAddInput:self.imput]){
//        [self addInput:self.imput];
//        // self.imput =videoImput;
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
//            AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
//            if (statusBarOrientation != UIInterfaceOrientationUnknown) {
//                initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
//            }
//            self.video.connection.videoOrientation = initialVideoOrientation;
//        });
//        
//    } else {
//        NSLog(@"No imput");
//        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
//        [self commitConfiguration];
//        return;
//    }
//}
//-(void)addOutPutForQR:(nullable id<AVCaptureMetadataOutputObjectsDelegate>)objectsDelegate{
//    self.output = [[AVCaptureMetadataOutput alloc] init];
//    if ([self canAddOutput:self.output]) {
//        [self addOutput:self.output];
//        [self.output setMetadataObjectsDelegate:objectsDelegate queue:dispatch_get_main_queue()];
//        self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
//    } else {
//        NSLog(@"No output");
//        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
//        [self commitConfiguration];
//        return;
//    }
//    
//    [self commitConfiguration];
//}
//-(void)addOutPutForText:(nullable id<AVCaptureVideoDataOutputSampleBufferDelegate>)sampleBufferDelegate{
//    
//    self.outputText = [[AVCaptureVideoDataOutput alloc] init];
//    if ([self canAddOutput:self.outputText]) {
//        [self addOutput:self.outputText];
//        [self.outputText setSampleBufferDelegate:sampleBufferDelegate queue:dispatch_get_main_queue()];
//    } else {
//        NSLog(@"No output");
//        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
//        [self commitConfiguration];
//        return;
//    }
//    [self commitConfiguration];
//}
////#pragma mark - Session For QR
////-(void)initSessionForView:(UIView*)view andMetadataObjectsDelegate:(nullable id<AVCaptureMetadataOutputObjectsDelegate>)objectsDelegate{
////    
////    
////    AVCaptureVideoPreviewLayer* layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[MainSession sharedSession]];
////    layer.frame = view.bounds;
////    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
////    [view.layer addSublayer:layer];
////    
////    
////    self.sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
////    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
////        case AVAuthorizationStatusAuthorized:{
////            break;
////        }
////        case AVAuthorizationStatusNotDetermined:{
////            dispatch_suspend(self.sessionQueue);
////            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
////                if (!granted) {
////                    self.setupResult = AVCamSetupResultNotAutorized;
////                }
////                dispatch_resume(self.sessionQueue);
////            }];
////            break;
////        }
////        default:
////            self.setupResult = AVCamSetupResultNotAutorized;
////            break;
////    }
////    
////    dispatch_async(self.sessionQueue, ^{
////        [self configureSessionAndMetadataObjectsDelegate:objectsDelegate];
////    });
////    
////}
////
////-(void)configureSessionAndMetadataObjectsDelegate:(nullable id<AVCaptureMetadataOutputObjectsDelegate>)objectsDelegate{
////    if (self.setupResult !=AVCamSetupResultSuccess) {
////        return;
////    }
////    NSError* error = nil;
////    [[MainSession sharedSession] beginConfiguration];
////    
////    AVCaptureDevice* device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
////    
////    //Imput
////    if(!device){
////        device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
////        if (!device) {
////            device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
////        }
////    }
////    self.imput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
////    if (!self.imput) {
////        NSLog(@"Imput errror - %@", [error localizedDescription]);
////        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
////        [[MainSession sharedSession] commitConfiguration];
////        return;
////    } else if ([[MainSession sharedSession] canAddInput:self.imput]){
////        [[MainSession sharedSession] addInput:self.imput];
////       // self.imput =videoImput;
////        
////        dispatch_async(dispatch_get_main_queue(), ^{
////            UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
////            AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
////            if (statusBarOrientation != UIInterfaceOrientationUnknown) {
////                initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
////            }
////            [MainSession sharedSession].video.connection.videoOrientation = initialVideoOrientation;
////        });
////        
////    } else {
////        NSLog(@"No imput QR");
////        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
////        [[MainSession sharedSession] commitConfiguration];
////        return;
////    }
////    
////    //Output
////    [MainSession sharedSession].output = [[AVCaptureMetadataOutput alloc] init];
////    if ([[MainSession sharedSession] canAddOutput:[MainSession sharedSession].output]) {
////        [[MainSession sharedSession] addOutput:[MainSession sharedSession].output];
////        [[MainSession sharedSession].output setMetadataObjectsDelegate:objectsDelegate queue:dispatch_get_main_queue()];
////        [MainSession sharedSession].output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
////    } else {
////        NSLog(@"No output");
////        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
////        [[MainSession sharedSession] commitConfiguration];
////        return;
////    }
////    
////    [[MainSession sharedSession] commitConfiguration];
////    //self.isStart = YES;
////}
//
////-(void)reloadSessionForView:(UIView*)view andMetadataObjectsDelegate:(nullable id<AVCaptureMetadataOutputObjectsDelegate>)objectsDelegate{
////    
////    [[MainSession sharedSession] removeInput:self.imput];
////    [[MainSession sharedSession] removeOutput:[MainSession sharedSession].output];
////    [[MainSession sharedSession] initSessionForView:view andMetadataObjectsDelegate:objectsDelegate];
////}
//
////#pragma mark - Sessiom For TextSearch
////-(void)initSessionForTextForSetSampleBufferDelegate:(nullable id<AVCaptureVideoDataOutputSampleBufferDelegate>)sampleBufferDelegate andImageView:(UIImageView*)imageView{
////    //self.session = [[AVCaptureSession alloc] init];
////    [MainSession sharedSessionForScanText].sessionPreset = AVCaptureSessionPresetPhoto;
////    
////    
////    self.sessionTextQueue = dispatch_queue_create("session queue2", DISPATCH_QUEUE_SERIAL);
////    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
////        case AVAuthorizationStatusAuthorized:{
////            break;
////        }
////        case AVAuthorizationStatusNotDetermined:{
////            dispatch_suspend(self.sessionTextQueue);
////            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
////                if (!granted) {
////                    self.setupResult = AVCamSetupResultNotAutorized;
////                }
////                dispatch_resume(self.sessionTextQueue);
////            }];
////            break;
////        }
////        default:
////            self.setupResult = AVCamSetupResultNotAutorized;
////            break;
////    }
////    
////    [self configureSessionForTextAndSetSampleBufferDelegate:sampleBufferDelegate andImageView:imageView];
////
////    
////}
////-(void)configureSessionForTextAndSetSampleBufferDelegate:(nullable id<AVCaptureVideoDataOutputSampleBufferDelegate>)sampleBufferDelegate andImageView:(UIImageView*)imageView{
////
////    if (self.setupResult !=AVCamSetupResultSuccess) {
////        return;
////    }
////    NSError* error = nil;
////    [[MainSession sharedSessionForScanText] beginConfiguration];
////
////    AVCaptureDevice* device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
////    if(!device){
////        device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
////        if (!device) {
////            device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
////        }
////    }
////    AVCaptureDeviceInput* videoImput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
////    if (!videoImput) {
////        NSLog(@"Imput errror - %@", [error localizedDescription]);
////        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
////        [[MainSession sharedSessionForScanText] commitConfiguration];
////        return;
////    } else if ([[MainSession sharedSessionForScanText] canAddInput:videoImput]){
////        [[MainSession sharedSessionForScanText] addInput:videoImput];
////        // self.imput =videoImput;
////
////        dispatch_async(dispatch_get_main_queue(), ^{
////            UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
////            AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
////            if (statusBarOrientation != UIInterfaceOrientationUnknown) {
////                initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
////            }
////            [MainSession sharedSessionForScanText].video.connection.videoOrientation = initialVideoOrientation;
////        });
////
////    } else {
////        NSLog(@"No imput TEXT");
////        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
////        [[MainSession sharedSessionForScanText] commitConfiguration];
////        return;
////    }
////
////
////    [MainSession sharedSessionForScanText].outputText = [[AVCaptureVideoDataOutput alloc] init];
////    if ([[MainSession sharedSessionForScanText] canAddOutput:[MainSession sharedSessionForScanText].outputText]) {
////        [[MainSession sharedSessionForScanText] addOutput:[MainSession sharedSessionForScanText].outputText];
////        [[MainSession sharedSessionForScanText].outputText setSampleBufferDelegate:sampleBufferDelegate queue:dispatch_get_main_queue()];
////
////    } else {
////        NSLog(@"No output");
////        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
////        [[MainSession sharedSessionForScanText] commitConfiguration];
////        return;
////    }
////
////    AVCaptureVideoPreviewLayer *imageLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[MainSession sharedSessionForScanText]];
////    //imageLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
////    imageLayer.frame = imageView.bounds;
////    [imageView.layer addSublayer:imageLayer];
////    [MainSession sharedSessionForScanText].videoForText = imageLayer;
////
////    [[MainSession sharedSessionForScanText] commitConfiguration];
////    //self.isStartText = YES;
////}
//
//@end
