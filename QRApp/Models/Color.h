//
//  Color.h
//  QRApp
//
//  Created by Сергей Семин on 22/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface Color : NSObject

@property(assign, nonatomic)CGFloat red;
@property(assign, nonatomic)CGFloat green;
@property(assign, nonatomic)CGFloat blue;

@property(assign, nonatomic)NSInteger hue;
@property(assign, nonatomic)NSInteger saturation;
@property(assign, nonatomic)NSInteger brigthess;


@end

NS_ASSUME_NONNULL_END
