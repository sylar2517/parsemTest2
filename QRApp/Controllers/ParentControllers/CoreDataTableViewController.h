//
//  CoreDataTableViewController.h
//  QRApp
//
//  Created by Сергей Семин on 29/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
NS_ASSUME_NONNULL_BEGIN

@interface CoreDataTableViewController : UITableViewController  <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath*)indexPath;
@end

NS_ASSUME_NONNULL_END
