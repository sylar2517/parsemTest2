//
//  WebViewController.h
//  QRApp
//
//  Created by Сергей Семин on 15/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class WKWebView, HistoryPost;
@interface WebViewController : UIViewController
@property(strong, nonatomic) NSArray* photoArray;
@property(strong, nonatomic) HistoryPost* post;
@property (weak, nonatomic) IBOutlet WKWebView *webView;

-(IBAction)actionBack:(UIBarButtonItem*)sender;
- (IBAction)actionShare:(UIBarButtonItem *)sender;

@end

NS_ASSUME_NONNULL_END
