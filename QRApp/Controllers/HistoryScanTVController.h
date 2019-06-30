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

@interface HistoryScanTVController : CoreDataTableViewController <NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

NS_ASSUME_NONNULL_END
