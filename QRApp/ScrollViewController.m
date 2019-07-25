//
//  ViewController.m
//  QRApp
//
//  Created by Сергей Семин on 26/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "ScrollViewController.h"

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

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    if (!decelerate) {
//        self.contentOffset = scrollView.contentOffset.x;
//        [self stopScrolling:self.contentOffset];
//    }
//}
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    NSLog(@"%@", [NSValue valueWithCGPoint:scrollView.contentOffset]);
//    self.contentOffset = scrollView.contentOffset.x;
//    [self stopScrolling:self.contentOffset];
//}
//
//-(void)stopScrolling:(NSInteger)interVal{
//    if (interVal > 1) {
//        self.navigationController.navigationBarHidden = NO;
//        [self.tabBarController.tabBar setHidden:NO];
//    } else {
//        self.navigationController.navigationBarHidden = YES;
//        [self.tabBarController.tabBar setHidden:YES];
//    }
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
