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

@interface ResultViewController () <UITextViewDelegate>

@end

@implementation ResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

    if (self.post && !self.fromCamera) {
        self.resultTextImageView.text = self.post.value;
        [self checkLing:self.post.value];
        NSData* dataPicture = self.post.picture;
        self.resultImageView.layer.magnificationFilter = kCAFilterNearest;
        self.resultImageView.image = [UIImage imageWithData:dataPicture];
        
    } else if (self.result && self.fromCamera){
        self.resultTextImageView.text = self.result;
        [self makeQRFromText:self.result];
        [self checkLing:self.result];
        
        [self save];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
        NSLog(@"Error result");
    }
    
    
    
    
    
    self.copingButton.tintColor = self.backButton.tintColor = [UIColor whiteColor];
    
    //[self makeQRFromText];
    //self.resultTextImageView.delegate = self;
    
    
}

#pragma mark - Methods
-(void)save{
    if (self.fromCamera && self.resultTextImageView.text) {
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

    BOOL result =   [string rangeOfString:@"www"].location != NSNotFound ||
                    [string rangeOfString:@"http"].location != NSNotFound ||
                    [string rangeOfString:@"com"].location != NSNotFound;
    
    if (result) {
        
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
    NSURL* URL = [NSURL URLWithString:self.resultTextImageView.text];
    [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
}

- (IBAction)actionSave:(UIButton *)sender {
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
}

- (IBAction)actionExport:(UIButton *)sender {

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
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.resultTextImageView resignFirstResponder];
}



@end
