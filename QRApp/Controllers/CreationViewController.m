//
//  CreationViewController.m
//  QRApp
//
//  Created by Сергей Семин on 01/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "CreationViewController.h"

@interface CreationViewController ()

@end

@implementation CreationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSArray* array = [[NSArray alloc] initWithObjects:self.simpleQR, self.customQR, nil];
    for (UIButton* object in array) {
        object.layer.cornerRadius = 10;
        object.layer.masksToBounds = YES;
    }
    self.createView.layer.cornerRadius = 10;
    self.createView.layer.masksToBounds = YES;
//    @property (weak, nonatomic) IBOutlet UIView *createView;
//    @property (weak, nonatomic) IBOutlet UIButton *simpleQR;
//    @property (weak, nonatomic) IBOutlet UIButton *customQR;

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
