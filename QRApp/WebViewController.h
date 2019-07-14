//
//  WebViewController.h
//  QRApp
//
//  Created by Сергей Семин on 15/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class WKWebView;
@interface WebViewController : UIViewController
@property(strong, nonatomic) NSMutableArray* photoArray;
@property (weak, nonatomic) IBOutlet WKWebView *webView;

-(IBAction)actionBack:(UIBarButtonItem*)sender;
- (IBAction)actionShare:(UIBarButtonItem *)sender;

@end

NS_ASSUME_NONNULL_END
