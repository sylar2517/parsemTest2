//
//  QRCollectionViewCell.h
//  QRApp
//
//  Created by Сергей Семин on 17/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class QRCollectionViewCell, QRPost;
@protocol QRCollectionViewCellDelegate
- (void)deleteCellForIndexPath:(QRPost*)post;
//- (void)showCellForQR:(QRPost*)post;
@end

@interface QRCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id <QRCollectionViewCellDelegate> delegate;
//@property(strong, nonatomic)NSIndexPath* index;
@property(strong, nonatomic)QRPost* post;


@property (weak, nonatomic) IBOutlet UIImageView *imageCell;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
//@property (weak, nonatomic) IBOutlet UIButton *infoButton;

- (IBAction)actionDelete:(UIButton *)sender;
//- (IBAction)actionShow:(UIButton *)sender;



@end

NS_ASSUME_NONNULL_END
