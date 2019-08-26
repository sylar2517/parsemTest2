//
//  ResultViewController.m
//  QRApp
//
//  Created by Сергей Семин on 27/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "ResultViewController.h"
#import "DataManager.h"
#import "HistoryPost+CoreDataClass.h"
#import <CoreData/CoreData.h>
#import "QRPost+CoreDataClass.h"
#import "ZoomViewController.h"

#import <AVFoundation/AVFoundation.h>
@import ZXingObjC;

@interface ResultViewController () <UITextViewDelegate>

@property(assign, nonatomic)NSInteger startCoordY;

@end

@implementation ResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.resultImageView.image = [UIImage imageNamed:@"mail"];
    
    self.parentView.layer.cornerRadius = 20;
    self.parentView.layer.masksToBounds = YES;
    
    self.mainView.layer.cornerRadius = 10;
    self.mainView.layer.masksToBounds = YES;
    
    self.resultTextImageView.editable = NO;
    self.resultTextImageView.layer.cornerRadius = 10;
    self.resultTextImageView.layer.masksToBounds = YES;
    
    NSArray* buttons = [[NSArray alloc] initWithObjects:self.copingButton, self.openInBrowser, self.backButton,self.saveButton, self.exportButton, nil];
    for (UIButton*but in buttons) {
        but.layer.cornerRadius = 10;
        but.layer.masksToBounds = YES;
    }

    self.openInBrowser.titleLabel.numberOfLines = 1;
    self.openInBrowser.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.openInBrowser.titleLabel.lineBreakMode = NSLineBreakByClipping;
    
    self.saveButton.titleLabel.numberOfLines = 1;
    self.saveButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.saveButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    
    self.exportButton.titleLabel.numberOfLines = 1;
    self.exportButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.exportButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    
    if (self.post && !self.fromCamera && !self.isBarcode) { // СКАНИРУЕМЫЙ QR ИЗ ИСТОРИИ
        self.resultTextImageView.text = self.post.value;
        [self checkLing:self.post.value];
        NSData* dataPicture = self.post.picture;
        self.resultImageView.layer.magnificationFilter = kCAFilterNearest;
        self.resultImageView.image = [UIImage imageWithData:dataPicture];
        self.backButton.hidden = YES;
        self.mainViewHeightConstraint.constant = self.mainViewHeightConstraint.constant - 50;

    }
    else if (self.result && self.fromCamera && !self.isBarcode){ // СКАНИРУЕМЫЙ QR ИЗ КАМЕРЫ
        self.resultTextImageView.text = self.result;
        [self makeQRFromText:self.result];
        [self checkLing:self.result];
        [self save];
        self.topLayoutConstraint.constant = 0;
        self.rollUpButton.hidden = YES;

    }
    else if (self.postQR && !self.fromCamera && !self.isBarcode){
        self.resultTextImageView.text = self.postQR.value; // КАСТОМНЫЙ QR ИЗ КАМЕРЫ
        [self checkLing:self.postQR.value];
        NSData* dataPicture = self.postQR.data;
        self.resultImageView.layer.magnificationFilter = kCAFilterNearest;
        self.resultImageView.image = [UIImage imageWithData:dataPicture];
        self.backButton.hidden = YES;
        self.mainViewHeightConstraint.constant = self.mainViewHeightConstraint.constant - 50;

    }
    else if (self.isBarcode && self.fromCamera) { //БАРКОД ИЗ КАМЕРЫ
#warning test
        
        self.rollUpButton.hidden = YES;
        self.resultTextImageView.text = self.result;
        
        if (self.AVMetadataObjectType == AVMetadataObjectTypeUPCECode) {
            [self makeBarcodeWithType:kBarcodeFormatUPCE];
        } else if (self.AVMetadataObjectType == AVMetadataObjectTypeCode39Code || self.AVMetadataObjectType == AVMetadataObjectTypeCode39Mod43Code) {
            [self makeBarcodeWithType:kBarcodeFormatCode39];
        }
        else if (self.AVMetadataObjectType == AVMetadataObjectTypeEAN13Code) {
            [self makeBarcodeWithType:kBarcodeFormatEan13];
        }
        else if (self.AVMetadataObjectType == AVMetadataObjectTypeEAN8Code) {
            [self makeBarcodeWithType:kBarcodeFormatEan8];
        }
        else if (self.AVMetadataObjectType == AVMetadataObjectTypeCode93Code) {
            [self makeBarcodeWithType:kBarcodeFormatCode93];
        }
        else if (self.AVMetadataObjectType == AVMetadataObjectTypeCode128Code) {
            [self makeBarcodeWithType:kBarcodeFormatCode128];
        }
        else if (self.AVMetadataObjectType == AVMetadataObjectTypePDF417Code) {
            [self makeBarcodeWithType:kBarcodeFormatPDF417];
        }
        
        self.openInBrowser.hidden = NO;
        [self.openInBrowser setTitle:@"Найти в Google" forState:(UIControlStateNormal)];
        [self.exportButton setTitle:@"Экспорт" forState:(UIControlStateNormal)];
        [self.saveButton setTitle:@"Сохранить" forState:(UIControlStateNormal)];
        
        [self save];
    } else if (self.post && !self.fromCamera && self.isBarcode){ //БАРКОД ИЗ ИСТОРИИ
        self.resultTextImageView.text = self.post.value;
        NSData* dataPicture = self.post.picture;
        self.resultImageView.image = [UIImage imageWithData:dataPicture];
        self.backButton.hidden = YES;
        self.mainViewHeightConstraint.constant = self.mainViewHeightConstraint.constant - 50;
        self.openInBrowser.hidden = NO;
        [self.openInBrowser setTitle:@"Найти в Google" forState:(UIControlStateNormal)];
        [self.exportButton setTitle:@"Экспорт" forState:(UIControlStateNormal)];
        [self.saveButton setTitle:@"Сохранить" forState:(UIControlStateNormal)];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
        NSLog(@"Error result");
    }
    
    
    
    
    self.copingButton.tintColor = self.backButton.tintColor = [UIColor whiteColor];
    



}


-(void)makeBarcodeWithType:(ZXBarcodeFormat)type{
    NSError *error = nil;
    ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
    ZXBitMatrix* result = [writer encode:self.result
                                  format:type
                                   width:500
                                  height:300
                                   error:&error];
    if (result) {
        CGImageRef image = CGImageRetain([[ZXImage imageWithMatrix:result] cgimage]);
        CGImageRelease(image);
        self.resultImageView.image = [UIImage imageWithCGImage:image];
    } else {
        NSString *errorMessage = [error localizedDescription];
        NSLog(@"%@", errorMessage);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    if (!self.fromCamera) {
        UITouch* touch = [touches anyObject];
        CGPoint pointOnMainView = [touch locationInView:self.view];
        self.startCoordY = pointOnMainView.y;
        
        if (self.startCoordY < 50) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!self.fromCamera) {
        UITouch* touch = [touches anyObject];
        CGPoint pointOnMainView = [touch locationInView:self.view];
        NSInteger delta = self.startCoordY - pointOnMainView.y;
        
        self.topLayoutConstraint.constant = 50-delta;
    }


}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    if (!self.fromCamera) {
        UITouch* touch = [touches anyObject];
        CGPoint pointOnMainView = [touch locationInView:self.view];
        
        NSInteger delta = self.startCoordY - pointOnMainView.y;
        if (delta < -100) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            self.topLayoutConstraint.constant = 50;
            
        }
    }
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    UITouch* touch = [touches anyObject];
    CGPoint pointOnMainView = [touch locationInView:self.view];
    
    NSInteger delta = self.startCoordY - pointOnMainView.y;
    if (delta < -100) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        self.topLayoutConstraint.constant = 50;
        
    }
}
#pragma mark - Methods
-(void)save{
    if (self.fromCamera && self.resultTextImageView.text && !self.isBarcode) {
        HistoryPost* post = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryPost" inManagedObjectContext:[DataManager sharedManager].persistentContainer.viewContext];
        NSDate* now = [NSDate date];
        post.dateOfCreation = now;
        post.value = self.resultTextImageView.text;
        post.type = @"QR";
        
        UIImage* image = self.resultImageView.image;
        
        UIGraphicsBeginImageContext(CGSizeMake(400, 400));
        [image drawInRect:CGRectMake(0, 0, 400, 400)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *imageData = UIImagePNGRepresentation(newImage);
        post.picture = imageData;
        
        [[DataManager sharedManager] saveContext];
    } else if (self.fromCamera && self.isBarcode) {
        HistoryPost* post = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryPost" inManagedObjectContext:[DataManager sharedManager].persistentContainer.viewContext];
        NSDate* now = [NSDate date];
        post.dateOfCreation = now;
        post.value = self.resultTextImageView.text;
        post.type = @"Штрихкод";
        
        UIImage* image = self.resultImageView.image;
        
        UIGraphicsBeginImageContext(CGSizeMake(500, 300));
        [image drawInRect:CGRectMake(0, 0, 500, 300)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *imageData = UIImagePNGRepresentation(newImage);
        post.picture = imageData;
        
        [[DataManager sharedManager] saveContext];
    }
}

-(void)makeQRFromText:(NSString*)string{
    NSData *stringData = [string dataUsingEncoding: NSUTF8StringEncoding];

    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];

    CIImage *qrImage = qrFilter.outputImage;
    float scaleX = self.resultImageView.frame.size.width / qrImage.extent.size.width;
    float scaleY = self.resultImageView.frame.size.height / qrImage.extent.size.height;

    qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];

    self.resultImageView.image = [UIImage imageWithCIImage:qrImage
                                                     scale:[UIScreen mainScreen].scale
                                               orientation:UIImageOrientationUp];


}
-(void)checkLing:(NSString*)string{

    NSDataDetector* detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray* matches = [detector matchesInString:string options:0 range:NSMakeRange(0, [string length])];

    if (matches.count > 0) {
         self.openInBrowser.hidden = NO;
    } else {
        self.openInBrowser.hidden = YES;
    }
}

#pragma mark - Actions
- (IBAction)actionBack:(UIButton *)sender {
    [self.resultTextImageView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionCopy:(UIButton *)sender {
    [UIPasteboard generalPasteboard].string = self.resultTextImageView.text;
}

- (IBAction)actionOpenInBrowser:(id)sender {

    if (!self.isBarcode){
        NSDataDetector* detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        NSArray* matches = [detector matchesInString:self.resultTextImageView.text options:0 range:NSMakeRange(0, [self.resultTextImageView.text length])];
        NSURL* URL = [(NSTextCheckingResult*)[matches firstObject] URL];
        
        [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
    } else {
        NSString* test = self.resultTextImageView.text;
        test = [test stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        test = [@"http://google.com/search?q=" stringByAppendingString:test];
        NSURL* URL = [NSURL URLWithString:test];
        
        [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
    }
    
}

- (IBAction)actionSave:(UIButton *)sender {
    if (!self.isBarcode) {
        UIImage* image = self.resultImageView.image;
        
        UIGraphicsBeginImageContext(CGSizeMake(400, 400));
        [image drawInRect:CGRectMake(0, 0, 400, 400)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil);
        
        UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"Сохранено" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction* aa = [UIAlertAction actionWithTitle:@"Ок" style:(UIAlertActionStyleCancel) handler:nil];
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
    } else {
        UIImage* image = self.resultImageView.image;
        
//        UIGraphicsBeginImageContext(CGSizeMake(400, 400));
//        [image drawInRect:CGRectMake(0, 0, 400, 400)];
//        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        
        UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"Сохранено" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction* aa = [UIAlertAction actionWithTitle:@"Ок" style:(UIAlertActionStyleCancel) handler:nil];
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
    }
    
}

- (IBAction)actionExport:(UIButton *)sender {

    
    if (!self.isBarcode) {
        UIImage* image = self.resultImageView.image;
        
        UIGraphicsBeginImageContext(CGSizeMake(400, 400));
        [image drawInRect:CGRectMake(0, 0, 400, 400)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *imageData = UIImagePNGRepresentation(newImage);
        
        NSArray* array = @[imageData];
        UIActivityViewController* avc = [[UIActivityViewController alloc] initWithActivityItems:array applicationActivities:nil];
        avc.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
        [self presentViewController:avc animated:YES completion:nil];
    } else {
        UIImage* image = self.resultImageView.image;
        NSData *imageData = UIImagePNGRepresentation(image);
        NSArray* array = @[imageData];
        UIActivityViewController* avc = [[UIActivityViewController alloc] initWithActivityItems:array applicationActivities:nil];
        avc.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
        [self presentViewController:avc animated:YES completion:nil];
    }
 
    
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [self.resultTextImageView resignFirstResponder];
//}

#pragma mark - Segue;
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"zoomSegue"]) {
        ZoomViewController* vc = segue.destinationViewController;
        UIImage* image = self.resultImageView.image;
        vc.isContact = NO;
        if (!self.isBarcode) {
            UIGraphicsBeginImageContext(CGSizeMake(400, 400));
            [image drawInRect:CGRectMake(0, 0, 400, 400)];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            vc.transferedImage = newImage;
        } else {
            vc.transferedImage = image;
        }
    
    }
}
@end
