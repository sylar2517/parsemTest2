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
    [df setDateFormat:@"dd MM yyyy HH mm"];
    
    NSString* name = [[df stringFromDate:now] stringByAppendingString:@".pdf"];
    NSURL* url2 = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:name]];
    [data writeToURL:url2 atomically:NO];
    self.pdfDoc = url2;
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

}
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
