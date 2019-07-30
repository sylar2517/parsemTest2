//
//  СhooseQRTableViewController.m
//  QRApp
//
//  Created by Сергей Семин on 18/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "СhooseQRTableViewController.h"
#import "EnterTextViewController.h"
#import "CustomQRTableViewController.h"

@interface ChooseQRTableViewController ()  <EnterTextViewControllerDelegate>
@end

@implementation ChooseQRTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationController.navigationBarHidden = NO;
//    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    self.navigationController.navigationBar.translucent = NO;
}
//- (void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//    [self.navigationItem setTitle:@""];
//}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < 3 || indexPath.row == 4 || indexPath.row == 5) {
        EnterTextViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EnterTextViewController"];
        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        vc.delegate = self;
        
        CATransition *transition = [[CATransition alloc] init];
        transition.duration = 0.8;
        transition.type = kCATransitionFade;
        transition.subtype = kCATransitionFromTop;
        [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        switch (indexPath.row) {
            case 0:
                vc.startString = @"Введите свой текст";
                vc.type = @"text";
                break;
            case 1:
                vc.startString = @"Введите свою электронную почту";
                vc.type = @"mail";
                break;
            case 2:
                vc.startString = @"Введите свою ссылку";
                vc.type = @"url";
                break;
            case 4:
                vc.type = @"date";
                break;
            case 5:
                vc.startString = @"Введите свой номер";
                vc.type = @"phone";
                break;
            default:
                break;
        }
        [self presentViewController:vc animated:YES completion:nil];
    }  else {
        UITableViewController* tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"testIDForPush"];
        [self.navigationController pushViewController:tvc animated:YES];
    }

    
}
#pragma mark - EnterTextViewControllerDelegate
-(void)textTransfer:(NSString*)string forType:(NSString*)type{
    NSLog(@"AAA - %@", type);
    CustomQRTableViewController* tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateQRTVC"];
    tvc.titleText = string;
    tvc.typeQR = type;
    [self.navigationController pushViewController:tvc animated:YES];
}
    
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    if ([segue.identifier isEqualToString:@"mailSegue"] || [segue.identifier isEqualToString:@"urlSegue"]) {
////        UIViewController* vc = segue.destinationViewController;
//        CATransition *transition = [[CATransition alloc] init];
//        transition.duration = 0.5;
//        transition.type = kCATransitionFade;
//        transition.subtype = kCATransitionFromTop;
//        [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
//        [self.view.window.layer addAnimation:transition forKey:kCATransition];
//    }
//}


@end
