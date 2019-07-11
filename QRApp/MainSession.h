//
//  MainSession.h
//  QRApp
//
//  Created by Сергей Семин on 11/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AVCamSetupResult) {
    AVCamSetupResultSuccess,
    AVCamSetupResultNotAutorized,
    AVCamSetupResultSessionConfigurationFailed
};

@interface MainSession : AVCaptureSession

@property(assign, nonatomic) AVCamSetupResult setupResult;

//@property(strong, nonatomic) AVCaptureSession* session;
//@property(assign, nonatomic) AVCamSetupResult setupResult;
//@property(nonatomic)dispatch_queue_t sessionQueue;
@property(strong, nonatomic)AVCaptureDeviceInput* imput;
@property(strong, nonatomic)AVCaptureVideoPreviewLayer *video;
//@property(strong, nonatomic)AVCaptureDevice* device;
@property(strong, nonatomic)AVCaptureMetadataOutput *output;
@property(nonatomic)dispatch_queue_t sessionQueue;
//@property(nonatomic)dispatch_queue_t sessionTextQueue;
//@property(assign, nonatomic)BOOL isStart;
//@property(assign, nonatomic)BOOL isStartText;

@property(strong, nonatomic)AVCaptureVideoDataOutput *outputText;
//@property(strong, nonatomic)AVCaptureVideoPreviewLayer *videoForText;
//@property(assign, nonatomic) BOOL sharedSessionIsRuning;

+(MainSession*)sharedSession;
-(void)initSessionForView:(UIView*)view forQRorText:(BOOL)qr;
-(void)addOutPutForQR:(nullable id<AVCaptureMetadataOutputObjectsDelegate>)objectsDelegate;
-(void)addOutPutForText:(nullable id<AVCaptureVideoDataOutputSampleBufferDelegate>)sampleBufferDelegate;
//-(void)initSessionForView:(UIView*)view andMetadataObjectsDelegate:(nullable id<AVCaptureMetadataOutputObjectsDelegate>)objectsDelegate;
//-(void)reloadSessionForView:(UIView*)view andMetadataObjectsDelegate:(nullable id<AVCaptureMetadataOutputObjectsDelegate>)objectsDelegate;

//+(MainSession*)sharedSessionForScanText;
//-(void)initSessionForTextForSetSampleBufferDelegate:(nullable id<AVCaptureVideoDataOutputSampleBufferDelegate>)sampleBufferDelegate andImageView:(UIImageView*)imageView;

@end

NS_ASSUME_NONNULL_END
