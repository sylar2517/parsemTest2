//
//  HictoryCell.m
//  QRApp
//
//  Created by Сергей Семин on 27/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "HistoryCell.h"

@implementation HistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.imageViewCell.layer.cornerRadius = 5;
    self.imageViewCell.layer.masksToBounds = YES;
    
   
    
    self.imageViewCell.backgroundColor = [UIColor whiteColor];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.dateLabel.textColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
