//
//  HistoryScanTVController.h
//  QRApp
//
//  Created by Сергей Семин on 24/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
NS_ASSUME_NONNULL_BEGIN
@class ScrollViewController, HistoryScanTVController, HistoryPost;
@protocol HistoryScanTVControllerDelegate
- (void)historyScanTVControllerPresentResult:(HistoryPost*)post;
-(void)showSideMunu;
@end


@interface HistoryScanTVController : CoreDataTableViewController <NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) id <HistoryScanTVControllerDelegate> hsDelegate;

- (IBAction)actionSettings:(id)sender;

@end

NS_ASSUME_NONNULL_END
