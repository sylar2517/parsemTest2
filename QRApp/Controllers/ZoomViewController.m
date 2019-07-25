//
//  ZoomViewController.m
//  QRApp
//
//  Created by Сергей Семин on 24/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "ZoomViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ZoomViewController ()

@end

@implementation ZoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
#warning START
    if (self.transferedImage) {
        self.exitButton.layer.cornerRadius = 15;
        self.exitButton.layer.masksToBounds = YES;
        self.QRImageView.image = self.transferedImage;
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
#warning END
    //self.QRImageView.image = [UIImage imageNamed:@"test"];
    //self.QRImageView.backgroundColor = [UIColor redColor];
//    UIImage* image1 = [self makeQRFromString:@"Hello"];
//    //UIImage* image2 = [UIImage imageNamed:@"test-1"];
//    UIImage* image2 = [UIImage imageNamed:@"test"];
//     //self.QRImageView.image = [UIImage imageNamed:@"test"];
//
//    //ВЕРНО
////    self.QRImageView.image = [self imageByCombiningImage:image2 withImage:image1];
//    UIImage* image3 = [self imageByCombiningImage:image2 withImage:image1];
//    [self getQRCode:image3];
//    self.QRImageView.image = image3;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)getQRCode:(UIImage*)image{
    @autoreleasepool {
        
        NSData* imageData = UIImagePNGRepresentation(image);
        CIImage* ciImage = [CIImage imageWithData:imageData];
        CIContext* context = [CIContext context];
        NSDictionary* options = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh }; // Slow but thorough
        
        CIDetector* qrDetector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                                    context:context
                                                    options:options];
        if ([[ciImage properties] valueForKey:(NSString*) kCGImagePropertyOrientation] == nil) {
            options = @{ CIDetectorImageOrientation : @1};
        } else {
            options = @{ CIDetectorImageOrientation : [[ciImage properties] valueForKey:(NSString*) kCGImagePropertyOrientation]};
        }
        
        NSArray * features = [qrDetector featuresInImage:ciImage
                                                 options:options];
        if (features != nil && features.count > 0) {
            for (CIQRCodeFeature* qrFeature in features) {
//                self.textView.text =qrFeature.messageString;
//                [self makeQRFromText:qrFeature.messageString];
//                self.isHaveResult = YES;
                NSLog(@"%@", qrFeature.messageString);
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                AudioServicesPlayAlertSound (1117);
            }
        } else {
//            self.textView.text =@"Ничего не обнаруженно";
//            self.isHaveResult = NO;
            NSLog(@"YOU LOUSE");
        }
        
    }
}

- (UIImage*)imageByCombiningImage:(UIImage*)firstImage withImage:(UIImage*)secondImage {
    UIImage *image = nil;
    
    CGSize size = self.QRImageView.frame.size;
    
    // UIGraphicsBeginImageContext(size);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [firstImage drawInRect:CGRectMake(0,0,size.width, size.height)];
    [secondImage drawInRect:CGRectMake(0,0,size.width, size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(UIImage*) makeQRFromString:(NSString*)string{
    NSData *stringData = [string dataUsingEncoding: NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIFilter* colorFilter =  [CIFilter filterWithName:@"CIFalseColor"];
    [colorFilter setValue:qrFilter.outputImage forKey:@"inputImage"];
    
    [colorFilter setValue:[CIColor clearColor] forKey:@"inputColor0"];
    [colorFilter setValue:[CIColor whiteColor] forKey:@"inputColor1"]; //back
    
    CIImage *qrImage = colorFilter.outputImage;
    
    
    float scaleX = self.QRImageView.frame.size.width / qrImage.extent.size.width;
    float scaleY = self.QRImageView.frame.size.height / qrImage.extent.size.height;
    
    qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];
    
    return [UIImage imageWithCIImage:qrImage
                                                 scale:[UIScreen mainScreen].scale
                                           orientation:UIImageOrientationUp];
}

- (IBAction)actionExtit:(UIButton *)sender {
     [self dismissViewControllerAnimated:YES completion:nil];
}
@end
