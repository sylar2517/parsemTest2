//
//  ViewController.h
//  QRApp
//
//  Created by Сергей Семин on 26/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ScrollViewController;
@protocol ScrollViewControllerDelegate
- (void) changeScreen:(BOOL)stopSession;
//-(void) test:(CGPoint)point;
@end

@interface ScrollViewController : UIViewController

@property (nonatomic, weak) id <ScrollViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *sideMenu;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sideMenuConstraint;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurEffect;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstrain;



@end

NS_ASSUME_NONNULL_END
