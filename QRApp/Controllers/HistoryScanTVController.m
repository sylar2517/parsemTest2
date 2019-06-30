//
//  HistoryScanTVController.m
//  QRApp
//
//  Created by Сергей Семин on 24/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "HistoryScanTVController.h"
#import "ViewController.h"
#import "HistoryCell.h"
#import "Models/HistoryPost+CoreDataClass.h"
#import "Controllers/ResultViewController.h"
#import "Controllers/PopUpForCameraOrGallery.h"
@interface HistoryScanTVController ()

@property(strong, nonatomic)NSMutableArray* filterObject;
@property(assign, nonatomic)BOOL isFiltered;

@end

@implementation HistoryScanTVController
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFiltered = NO;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
}



- (NSFetchedResultsController*) fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* description = [NSEntityDescription entityForName:@"HistoryPost" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:description];
    [request setFetchBatchSize:20];
    NSSortDescriptor* sdName = [NSSortDescriptor sortDescriptorWithKey:@"dateOfCreation" ascending:NO];
    [request setSortDescriptors:@[sdName]];
    
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    
    _fetchedResultsController = aFetchedResultsController;
    return _fetchedResultsController;
}

#pragma mark - UITableViewDataSourse
- (void)configureCell:(HistoryCell *)cell atIndexPath:(NSIndexPath*)indexPath{
    
    HistoryPost* post = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.nameLabel.text = post.value;
    
//    UIImage* image = [UIImage imageWithData:post.picture];
//    //cell.imageViewCell.image = [UIImage imageWithData:post.picture];
//    cell.imageViewCell.image = image;
    
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
   // [df setDateStyle:(NSDateFormatterFullStyle)];
    [df setDateFormat:@"dd-MM-yyyy HH:mm"];
    cell.dateLabel.text = [df stringFromDate:post.dateOfCreation];
    
    
//    CIImage *qrImage = [CIImage imageWithData:post.picture];
//    float scaleX = cell.imageViewCell.frame.size.width / qrImage.extent.size.width;
//    float scaleY = cell.imageViewCell.frame.size.height / qrImage.extent.size.height;
//
//    qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];
//    UIImage* image = [UIImage imageWithCIImage:qrImage
//                                         scale:[UIScreen mainScreen].scale
//                                   orientation:UIImageOrientationUp];
    cell.imageViewCell.image = [self makeQRFromText:post.value from:cell.imageViewCell];
   // cell.imageViewCell.layer.magnificationFilter = kCAFilterNearest;
}


-(UIImage*)makeQRFromText:(NSString*)text from:(UIImageView*)imageView{
    
    NSData *stringData = [text dataUsingEncoding: NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrImage = qrFilter.outputImage;
    float scaleX = imageView.frame.size.width / qrImage.extent.size.width;
    float scaleY = imageView.frame.size.height / qrImage.extent.size.height;
    
    qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];
    
    return [UIImage imageWithCIImage:qrImage
                             scale:[UIScreen mainScreen].scale
                       orientation:UIImageOrientationUp];
    
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HistoryPost* post = [self.fetchedResultsController objectAtIndexPath:indexPath];
    ResultViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"resultVC"];
    vc.result = post.value;
    [self presentViewController:vc animated:YES completion:nil];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.f;
}


//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    if (self.isFiltered) {
//        return self.filterObject.count;
//    } else {
//        return [super tableView:tableView numberOfRowsInSection:section];
//    }
//}


#pragma mark -  UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.tableView reloadData];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
//    NSLog(@"aaa");
//    //[self generateSectionsInBackgroundFromArray:self.searchArray withFilter:self.searchBar.text];
//    self.isFiltered = YES;
//    [self filterContentForSearchText:self.searchBar.text scope:nil];
//    if (searchText.length == 0) {
//        self.isFiltered = NO;
//    } else {
//        self.isFiltered = YES;
//        self.filterObject = [NSMutableArray array];
//        [self filterContentForSearchText:searchText];
//    }
//
}
#pragma mark -  Private Methods


- (void)filterContentForSearchText:(NSString*)searchText
{
    //    self.savedSearchTerm = searchText;
    //
    //    freshData = NO;
    self.isFiltered = NO;
    if (searchText !=nil)
    {
        NSPredicate *predicate =[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchText];
        [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    }
    else
    {
        NSPredicate *predicate =[NSPredicate predicateWithFormat:@"All"];
        [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    }
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [self.tableView reloadData];
    
    //    [searchBar resignFirstResponder];
    //    [_shadeView setAlpha:0.0f];
    
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    if ([segue.identifier isEqualToString:@"popUpForCamera"]) {
//        PopUpForCameraOrGallery* vc = segue.destinationViewController;
//        vc.fromMenu = YES;
//    }
//}


@end
