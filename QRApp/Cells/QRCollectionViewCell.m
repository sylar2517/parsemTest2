//
//  QRCollectionViewCell.m
//  QRApp
//
//  Created by Сергей Семин on 17/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "QRCollectionViewCell.h"

@implementation QRCollectionViewCell

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.layer.cornerRadius = 10;
    self.layer.shadowRadius = 10;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowOffset = CGSizeMake(5, 8);
    self.layer.masksToBounds = NO;
    
    self.imageCell.layer.cornerRadius = 5;
    self.imageCell.layer.masksToBounds = YES;
    
    self.deleteButton.layer.cornerRadius = 5;
    self.deleteButton.layer.masksToBounds = YES;
    
    self.infoButton.layer.cornerRadius = 5;
    self.infoButton.layer.masksToBounds = YES;
}

@end
