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
- (void)historyScanTVControllerPresentResultBarcode:(HistoryPost*)post;
-(void)showSideMunu;
@end


@interface HistoryScanTVController : CoreDataTableViewController <NSFetchedResultsControllerDelegate>

@property(strong, nonatomic)NSString* sort;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) id <HistoryScanTVControllerDelegate> hsDelegate;

-(void)setEditingHistory;
-(void)clearHistory;
-(void)showAll;
-(void)showQR;
-(void)showPDF;
-(void)showBarcode;

- (IBAction)actionSettings:(id)sender;

@end

NS_ASSUME_NONNULL_END
