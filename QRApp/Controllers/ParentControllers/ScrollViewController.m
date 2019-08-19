//
//  ViewController.m
//  QRApp
//
//  Created by Сергей Семин on 26/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "ScrollViewController.h"
#import "QRViewController.h"
#import "ResultViewController.h"

#import "HistoryScanTVController.h"
#import "SideMenuTableViewController.h"

@interface ScrollViewController () <UIScrollViewDelegate, QRViewControllerDelegate, HistoryScanTVControllerDelegate, SideMenuTableViewControllerDelegate>

@property(assign, nonatomic)BOOL firstTime;
@property(strong, nonatomic) UIButton* sideMenuExitButton;
@property(strong, nonatomic) HistoryScanTVController* historyVC;

@end

@implementation ScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   // NSLog(@"%f", self.widthConstrain.constant);
    self.widthConstrain.constant = CGRectGetWidth(self.view.bounds);
    [self.view layoutIfNeeded];

    self.navigationController.navigationBarHidden = YES;
    [self.tabBarController.tabBar setHidden:YES];
    self.firstTime = YES;
    
    
    self.sideMenuConstraint.constant = CGRectGetWidth(self.view.bounds);
    self.sideMenu.layer.shadowOpacity = 1;
    
    
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //CGFloat x = self.scrollView.contentOffset.x;
    
    if (self.scrollView.contentOffset.x == CGRectGetWidth(self.view.frame)) {
        [self.delegate changeScreen:YES];
    }
}

//- (void)viewDidAppear:(BOOL)animated{
//
//    if (self.firstTime) {
//        self.firstTime = NO;
//        self.navigationController.navigationBarHidden = YES;
//        [self.tabBarController.tabBar setHidden:YES];
//    }
//}
#pragma mark - SideMenuTableViewControllerDelegate
- (void)dissMissSideMenuTVC{
    self.scrollView.scrollEnabled = YES;
    self.sideMenuConstraint.constant = CGRectGetWidth(self.view.bounds);
    [self.tabBarController.tabBar setHidden:NO];
    self.blurEffect.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    if (self.sideMenuExitButton) {
        [self.sideMenuExitButton removeFromSuperview];
    }
}
- (void)setEditing{
    [self.historyVC setEditingHistory];
}
- (void)clearHistory{
    [self.historyVC clearHistory];
}
- (void)showAll{
    [self.historyVC showAll];
}
-(void)showQR{
    [self.historyVC showQR];
}
-(void)showPDF{
    [self.historyVC showPDF];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    NSInteger test = CGRectGetWidth(self.view.bounds) - 1;
    if (scrollView.contentOffset.x > test) {
        self.navigationController.navigationBarHidden = NO;
        [self.tabBarController.tabBar setHidden:NO];
    } else {
        self.navigationController.navigationBarHidden = YES;
        [self.tabBarController.tabBar setHidden:YES];
        [self.historyVC.searchBar resignFirstResponder];
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

#pragma mark - QRVCDelegate

- (void)pushResultVC:(NSString*)string{
    ResultViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"resultVC"];
    vc.result = string;
    vc.fromCamera = YES;
    //vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - HVCDelegate

-(void)historyScanTVControllerPresentResult:(HistoryPost *)post{
    ResultViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"resultVC"];
    vc.post = post;
    vc.fromCamera = NO;
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)showSideMunu{
    
    self.scrollView.scrollEnabled = NO;
    self.sideMenuConstraint.constant = 110;
    [self.tabBarController.tabBar setHidden:YES];
    self.blurEffect.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        
        
        [self.view layoutIfNeeded];
    }];
    
    UIButton* button = [[UIButton alloc] initWithFrame:
                        CGRectMake(CGRectGetMinX(self.view.bounds),
                                   CGRectGetMinX(self.view.bounds),
                                   
                                   110,//CGRectGetWidth(self.view.bounds)/2,
                                   CGRectGetHeight(self.view.bounds))];
    //button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(clouseSideMenu:) forControlEvents:(UIControlEventTouchUpInside)];
    
    [self.view addSubview:button];
    self.sideMenuExitButton = button;
    
    //[self.view layoutIfNeeded];
}

-(void)clouseSideMenu:(UIButton*)sender{
    self.scrollView.scrollEnabled = YES;
    self.sideMenuConstraint.constant = CGRectGetWidth(self.view.bounds);
    [self.tabBarController.tabBar setHidden:NO];
    self.blurEffect.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    [sender removeFromSuperview];
    
    NSLog(@"%@", self.historyVC);
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"camSegue"]) {
        QRViewController* vc = segue.destinationViewController;
        vc.delegate = self;
        vc.parent = self;
    } else if ([segue.identifier isEqualToString:@"historySegue"]) {
//        HistoryScanTVController* vc = segue.destinationViewController;
//        vc.hsDelegate = self;
        UINavigationController* nav = segue.destinationViewController;
        self.historyVC = (HistoryScanTVController*)nav.topViewController;
        [(HistoryScanTVController*)nav.topViewController setHsDelegate:self];
    }
    else if ([segue.identifier isEqualToString:@"sideMenu"]) {
        SideMenuTableViewController* vc = segue.destinationViewController;
        vc.delegate = self;
        
    }
}


@end
