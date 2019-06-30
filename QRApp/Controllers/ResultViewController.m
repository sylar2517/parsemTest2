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
    // Do any additional setup after loading the view.
    if ([self.result rangeOfString:@"http"].location == NSNotFound) {
        self.openInBrowser.hidden = YES;
    } else {
        self.openInBrowser.hidden = NO;
        self.openInBrowser.tintColor = [UIColor whiteColor];
    }
    
    self.mainView.layer.cornerRadius = 10;
    self.mainView.layer.masksToBounds = YES;
    
    NSArray* buttons = [[NSArray alloc] initWithObjects:self.copingButton, self.openInBrowser, self.backButton, nil];
    for (UIButton*but in buttons) {
        but.layer.cornerRadius = 10;
        but.layer.masksToBounds = YES;
    }

    
    self.resultTextImageView.text = self.result;
    self.resultTextImageView.editable = NO;
    self.resultTextImageView.layer.cornerRadius = 10;
    self.resultTextImageView.layer.masksToBounds = YES;
    
    self.copingButton.tintColor = self.backButton.tintColor = [UIColor whiteColor];
    
    [self makeQRFromText];
    self.resultTextImageView.delegate = self;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView{
    [self makeQRFromText];
}

#pragma mark - Methods
-(void)makeQRFromText{
    //    CIImage* ciImage = [self createQRForString:self.result];
    //    UIImage* image = [UIImage imageWithCIImage:ciImage];
    //    self.resultImageView.image = image;
//    CIImage *qrImage = [self createQRForString:self.result];
//    float scaleX = self.resultImageView.frame.size.width / qrImage.extent.size.width;
//    float scaleY = self.resultImageView.frame.size.height / qrImage.extent.size.height;
//
//    qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];
//
//    self.resultImageView.image = [UIImage imageWithCIImage:qrImage
//                                                     scale:[UIScreen mainScreen].scale
//                                               orientation:UIImageOrientationUp];
    
        
    NSData *stringData = [self.result dataUsingEncoding: NSUTF8StringEncoding];
    
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
//- (CIImage *)createQRForString:(NSString *)qrString {
//    NSData *stringData = [qrString dataUsingEncoding: NSISOLatin1StringEncoding];
//    
//    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
//    [qrFilter setValue:stringData forKey:@"inputMessage"];
//
//    return qrFilter.outputImage;
//    
//    //    HistoryPost* post = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryPost" inManagedObjectContext:[DataManager sharedManager].persistentContainer.viewContext];
//        NSDate* now = [NSDate date];
//        post.dateOfCreation = now;
//        post.value = qrString;
//        post.picture = stringData;
//    //
//    //    [[DataManager sharedManager] saveContext];
//}


#pragma mark - Actions
- (IBAction)actionBack:(UIButton *)sender {
    [self.resultTextImageView resignFirstResponder];
    
    if (self.fromCamera) {
        HistoryPost* post = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryPost" inManagedObjectContext:[DataManager sharedManager].persistentContainer.viewContext];
        NSDate* now = [NSDate date];
        post.dateOfCreation = now;
        post.value = self.resultTextImageView.text;

    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionCopy:(UIButton *)sender {
    [UIPasteboard generalPasteboard].string = self.resultTextImageView.text;
}

- (IBAction)actionOpenInBrowser:(id)sender {
    NSURL* URL = [NSURL URLWithString:self.resultTextImageView.text];
    [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.resultTextImageView resignFirstResponder];
}




// #pragma mark - Navigation
//
// // In a storyboard-based application, you will often want to do a little preparation before navigation
// - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//     if ([segue.identifier isEqualToString:@"webController"]) {
//         WebViewController* vc = segue.destinationViewController;
//         vc.URLString = self.resultTextImageView.text;
//     }
// }

@end
