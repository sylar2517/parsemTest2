//
//  SettingsViewController.m
//  QRApp
//
//  Created by Сергей Семин on 03/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSArray* array = @[self.tableViewContainer, self.appSettingsView];
    for (UIView* view in array) {
        view.layer.cornerRadius = 10;
        view.layer.masksToBounds = YES;
    }
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
