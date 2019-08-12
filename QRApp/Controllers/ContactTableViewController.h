//
//  ContactTableViewController.h
//  QRApp
//
//  Created by Сергей Семин on 19/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactTableViewController : UITableViewController

@property(strong, nonatomic)NSString* meCard;
@property(strong, nonatomic)NSData* imageData;


@property (weak, nonatomic) IBOutlet UIButton *contactButton;

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;

- (IBAction)actionSelectContact:(UIButton *)sender;

@end

NS_ASSUME_NONNULL_END
