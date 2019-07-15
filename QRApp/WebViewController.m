//
//  WebViewController.m
//  QRApp
//
//  Created by Сергей Семин on 15/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>
#import <PDFKit/PDFKit.h>

@interface WebViewController () <WKNavigationDelegate>
@property(strong, nonatomic) NSURL* pdfDoc;
@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.webView.navigationDelegate = self;
    NSLog(@"%@", self.photoArray);
    
    PDFDocument* pdfDoc = [[PDFDocument alloc] init];
    for (int i = 0; i < self.photoArray.count; i++) {
        PDFPage* pdfPage = [[PDFPage alloc] initWithImage:[self.photoArray objectAtIndex:i]];
        [pdfDoc insertPage:pdfPage atIndex:i];
    }

    NSData* data = pdfDoc.dataRepresentation;

    NSURL* url = [NSURL URLWithString:@""];
    [self.webView loadData:data
                  MIMEType:@"application/pdf"
     characterEncodingName:@"UTF-8"
                   baseURL:url];

    NSDate* now = [NSDate date];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd-MM-yyyy HH:mm"];

    NSString* name = [[df stringFromDate:now] stringByAppendingString:@".pdf"];
    NSURL* url2 = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:name]];
    [data writeToURL:url2 atomically:NO];
    self.pdfDoc = url2;
    
    //NSString* urlString = @"https://en.wikipedia.org/wiki/QR_code";
//       NSString* urlString = @"https://www.google.com/search?q=qr+code&newwindow=1&source=lnms&tbm=isch&sa=X&ved=0ahUKEwjTuvCdw7fjAhWNyqYKHc9JA10Q_AUIECgB&biw=1440&bih=718";
//    NSURL* url = [NSURL URLWithString:urlString];
//    NSURLRequest* request = [NSURLRequest requestWithURL:url];
//    [self.webView loadRequest:request];

}
#pragma mark - Actions -

-(IBAction)actionBack:(UIBarButtonItem*)sender{
   
    if (sender.tag == 1) {
        //не сохранять
    } else {
        //сохранить
    }
        
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionShare:(UIBarButtonItem *)sender {
    NSArray* array = @[self.pdfDoc];
    UIActivityViewController* avc = [[UIActivityViewController alloc] initWithActivityItems:array applicationActivities:nil];
    avc.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
    [self presentViewController:avc animated:YES completion:nil];
   
    //[self getQRCode];
}
//-(void)getQRCode{
//    @autoreleasepool {
//        
//        //NSData* imageData = UIImagePNGRepresentation(self.selectedImage);
//        //NSString* urlString = @"https://en.wikipedia.org/wiki/QR_code";
//         NSString* urlString = @"https://www.google.com/search?q=qr+code&newwindow=1&source=lnms&tbm=isch&sa=X&ved=0ahUKEwjTuvCdw7fjAhWNyqYKHc9JA10Q_AUIECgB&biw=1440&bih=718";
//        NSURL* url = [NSURL URLWithString:urlString];
//        NSData* data = [NSData dataWithContentsOfURL:url];
//        CIImage* ciImage = [CIImage imageWithData:data];
//        CIContext* context = [CIContext context];
//        NSDictionary* options = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh }; // Slow but thorough
//        
//        CIDetector* qrDetector = [CIDetector detectorOfType:CIDetectorTypeQRCode
//                                                    context:context
//                                                    options:options];
//        if ([[ciImage properties] valueForKey:(NSString*) kCGImagePropertyOrientation] == nil) {
//            options = @{ CIDetectorImageOrientation : @1};
//        } else {
//            options = @{ CIDetectorImageOrientation : [[ciImage properties] valueForKey:(NSString*) kCGImagePropertyOrientation]};
//        }
//        
//        NSArray * features = [qrDetector featuresInImage:ciImage
//                                                 options:options];
//        if (features != nil && features.count > 0) {
//            for (CIQRCodeFeature* qrFeature in features) {
////                self.textView.text =qrFeature.messageString;
////                [self makeQRFromText:qrFeature.messageString];
////                self.isHaveResult = YES;
//                NSString* string = qrFeature.messageString;
//                NSLog(@"%@", string);
//            }
//        } else {
////            self.textView.text =@"Ничего не обнаруженно";
////            self.isHaveResult = NO;
//        }
//        
//    }
//    
//}
#pragma mark - WKNavigationDelegate -

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSURLRequest *request = navigationAction.request;
    
    decisionHandler(WKNavigationActionPolicyAllow);
    
    NSString *url = [[request URL]absoluteString];
    
    if ([url hasPrefix:@"cmd"]) {
        NSString* command = [url substringFromIndex:4];
        if ([command isEqualToString:@"show_allert"]) {
            UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"Error" message:command preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction* actionCansel = [UIAlertAction actionWithTitle:@"cansel" style:(UIAlertActionStyleCancel) handler:nil];
            [ac addAction:actionCansel];
            [self presentViewController:ac animated:YES completion:nil];
        }
        return;
    }
    NSLog(@"%@", url);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{

}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{

}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{

}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end
