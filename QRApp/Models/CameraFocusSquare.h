//
//  CameraFocusSquare.h
//  QRApp
//
//  Created by Сергей Семин on 22/08/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraFocusSquare : UIView <CAAnimationDelegate>

- (instancetype)initWithTouchPoint:(CGPoint)touchPoint;
- (void)updatePoint:(CGPoint)touchPoint;
- (void)animateFocusingAction;

@end

NS_ASSUME_NONNULL_END
