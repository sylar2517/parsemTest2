//
//  ViewController.m
//  QRApp
//
//  Created by Сергей Семин on 26/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "ScrollViewController.h"
#import "QRViewController.h"

@interface ScrollViewController () <UIScrollViewDelegate>
//@property(assign, nonatomic)NSInteger contentOffset;
@property(assign, nonatomic)BOOL firstTime;
@end

@implementation ScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   // NSLog(@"%f", self.widthConstrain.constant);
    self.widthConstrain.constant = CGRectGetWidth(self.view.bounds);
    [self.view layoutIfNeeded];

    self.navigationController.navigationBarHidden = NO;
    [self.tabBarController.tabBar setHidden:NO];
    self.firstTime = YES;
    
}
- (void)viewDidAppear:(BOOL)animated{

    if (self.firstTime) {
        self.firstTime = NO;
        self.navigationController.navigationBarHidden = YES;
        [self.tabBarController.tabBar setHidden:YES];
    }
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    NSInteger test = CGRectGetWidth(self.view.bounds)/2;
    if (scrollView.contentOffset.x > test) {
        self.navigationController.navigationBarHidden = NO;
        [self.tabBarController.tabBar setHidden:NO];
    } else {
        self.navigationController.navigationBarHidden = YES;
        [self.tabBarController.tabBar setHidden:YES];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        [self stopScrolling:scrollView.contentOffset.x];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
        [self stopScrolling:scrollView.contentOffset.x];
}

-(void)stopScrolling:(NSInteger)interVal{
    if (interVal > 1) {
        [self.delegate changeScreen:YES];
    } else {
        [self.delegate changeScreen:NO];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"camSegue"]) {
        QRViewController* vc = segue.destinationViewController;
        vc.parent = self;
    }
}


@end
