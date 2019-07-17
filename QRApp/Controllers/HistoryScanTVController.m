//
//  HistoryScanTVController.m
//  QRApp
//
//  Created by Сергей Семин on 24/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "HistoryScanTVController.h"
#import "QRViewController.h"
#import "HistoryCell.h"
#import "HistoryPost+CoreDataClass.h"
#import "ResultViewController.h"
#import "PopUpForCameraOrGallery.h"
#import "DataManager.h"

#import "WebViewController.h"

@interface HistoryScanTVController () <PopUpForCameraOrGalleryDelegate>

@property(strong, nonatomic)NSMutableArray* filterObject;
@property(assign, nonatomic)BOOL isFiltered;
@property(assign, nonatomic)BOOL isEditing;
@property(strong, nonatomic)NSMutableArray* tempObjectArray;

@property(strong, nonatomic)NSArray*withExport;
@property(strong, nonatomic)NSArray*withOutExport;


@end

@implementation HistoryScanTVController
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isFiltered = NO;
    self.isEditing = NO;
    
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:[UIColor whiteColor]];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitle:@"Отмена"];
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    self.navigationController.toolbar.tintColor = [UIColor whiteColor];
    UIBarButtonItem* export = [[UIBarButtonItem alloc] initWithTitle:@"Экспорт" style:(UIBarButtonItemStylePlain) target:self action:@selector(actionExport:)];
    UIBarButtonItem* flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemFlexibleSpace) target:self action:nil];
    UIBarButtonItem* delete = [[UIBarButtonItem alloc] initWithTitle:@"Удалить" style:(UIBarButtonItemStylePlain) target:self action:@selector(actionDelete:)];
    UIBarButtonItem* cancel = [[UIBarButtonItem alloc] initWithTitle:@"Отмена" style:(UIBarButtonItemStylePlain) target:self action:@selector(actionCancelEditing:)];
    cancel.tintColor = [UIColor redColor];
    
    self.withExport =@[cancel, flex,  export, flex, delete];
    self.withOutExport = @[cancel, flex, delete];
    
    self.toolbarItems = self.withExport;
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
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.searchBar resignFirstResponder];
}

#pragma mark - UITableViewDataSourse
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* identifier = @"historyCell";
    HistoryCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    //    if (!cell) {
    //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    //        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(HistoryCell *)cell atIndexPath:(NSIndexPath*)indexPath{
    HistoryPost* post = nil;
    if (self.filterObject) {
        post = [self.filterObject objectAtIndex:indexPath.row];
    } else {
        post = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    //HistoryPost* post = [self.fetchedResultsController objectAtIndexPath:indexPath];
   
    //cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.tintColor = [UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.nameLabel.textColor = [UIColor whiteColor];
    cell.dateLabel.textColor = [UIColor whiteColor];
    
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd-MM-yyyy HH:mm"];
    cell.dateLabel.text = [df stringFromDate:post.dateOfCreation];


    
    if ([post.type isEqualToString:@"QR"]) {
        cell.nameLabel.text = post.value;
        cell.imageViewCell.layer.magnificationFilter = kCAFilterNearest;
        cell.imageViewCell.image = [UIImage imageWithData:post.picture];
        cell.typeLabel.text = @"QR";

        
    } else if ([post.type isEqualToString:@"PDF"]){
        cell.nameLabel.text = post.value;
        cell.imageViewCell.image = [UIImage imageNamed:@"pdf"];
        cell.imageViewCell.backgroundColor = [UIColor redColor];
        cell.typeLabel.text = @"PDF";
    }
    
    
    
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   // [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!self.isEditing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        HistoryPost* post = nil;
        if (self.filterObject) {
            post = [self.filterObject objectAtIndex:indexPath.row];
        } else {
            post = [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
        
        if ([post.type isEqualToString:@"QR"]) {
            ResultViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"resultVC"];
            vc.post = post;
            vc.fromCamera = NO;
            [self presentViewController:vc animated:YES completion:nil];
        } else if ([post.type isEqualToString:@"PDF"]) {
            WebViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"webView"];
            vc.post = post;
            [self presentViewController:vc animated:YES completion:nil];
        }
        
    } else {
        
        HistoryPost* post = nil;
        if (self.filterObject) {
            post = [self.filterObject objectAtIndex:indexPath.row];
        } else {
            post = [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
        
        [self.tempObjectArray addObject:post];
        
        if(self.tempObjectArray.count > 1){
            self.toolbarItems = self.withOutExport;
        } else {
            self.toolbarItems = self.withExport;
        }
        
        HistoryCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.nameLabel.textColor = [UIColor blackColor];
        cell.dateLabel.textColor = [UIColor blackColor];
        cell.typeLabel.textColor = [UIColor blackColor];
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!self.isEditing) {
        return;
    } else {
       
        HistoryPost* post = nil;
        if (self.filterObject) {
            post = [self.filterObject objectAtIndex:indexPath.row];
        } else {
            post = [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
        [self.tempObjectArray removeObject:post];
        
        if(self.tempObjectArray.count > 1){
            self.toolbarItems = self.withOutExport;
        } else {
            self.toolbarItems = self.withExport;
        }
        
        HistoryCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.nameLabel.textColor = [UIColor whiteColor];
        cell.dateLabel.textColor = [UIColor whiteColor];
        cell.typeLabel.textColor = [UIColor whiteColor];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isFiltered) {
        self.isFiltered = NO;
        //NSLog(@"%lu", (unsigned long)self.filterObject.count);
        return self.filterObject.count;
    } else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 3;
}

- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    UIContextualAction* action = [UIContextualAction contextualActionWithStyle:(UIContextualActionStyleNormal) title:@"Удалить" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        HistoryPost* post = nil;
        if (self.filterObject) {
            post = [self.filterObject objectAtIndex:indexPath.row];
        } else {
            post = [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
        [[DataManager sharedManager].persistentContainer.viewContext deleteObject:post];
        [[DataManager sharedManager] saveContext];
    }];
    action.backgroundColor = [UIColor redColor];
    return [UISwipeActionsConfiguration configurationWithActions:@[action]];
}

#pragma mark -  UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    searchBar.text = nil;
    self.filterObject = nil;
    [self.tableView reloadData];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{

    self.isFiltered = YES;
    if (searchText.length == 0) {
        self.isFiltered = NO;
        self.filterObject = nil;
        [self.tableView reloadData];
    } else {
        self.isFiltered = YES;
        self.filterObject = [NSMutableArray array];
        [self filterContentForSearchText:searchText];
    }
//
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}
#pragma mark -  Private Methods
- (void)filterContentForSearchText:(NSString*)searchText
{
    //    self.savedSearchTerm = searchText;
    //
    //    freshData = NO;
    
    if (searchText !=nil)
    {
        NSPredicate *predicate =[NSPredicate predicateWithFormat:@"value contains[cd] %@", searchText];
        //        [self.fetchedResultsController.fetchRequest setPredicate:predicate];
        NSFetchRequest* request = [[NSFetchRequest alloc] init];
        NSEntityDescription* description = [NSEntityDescription entityForName:@"HistoryPost" inManagedObjectContext:self.managedObjectContext];
        [request setEntity:description];
        [request setFetchBatchSize:20];
        [request setPredicate:predicate];
        NSSortDescriptor* sdName = [NSSortDescriptor sortDescriptorWithKey:@"dateOfCreation" ascending:NO];
        [request setSortDescriptors:@[sdName]];
        NSError* reqestError = nil;
        NSArray* resultArray = [[DataManager sharedManager].persistentContainer.viewContext executeFetchRequest:request error:&reqestError];
        if (reqestError) {
            NSLog(@"%@", [reqestError localizedDescription]);
            self.filterObject = nil;
        } else {
            self.filterObject = [NSMutableArray arrayWithArray:resultArray];
        }
        
        
    }
    //    else {
    //        self.filterObject = nil;
    //    }
    else
    {
        NSPredicate *predicate =[NSPredicate predicateWithFormat:@"All"];
        [self.fetchedResultsController.fetchRequest setPredicate:predicate];
        self.filterObject = nil;
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




#pragma mark -  Actions storyboard
- (IBAction)actionSettings:(id)sender{
    
    UIAlertController* ac = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    
    UIAlertAction* aa = [UIAlertAction actionWithTitle:@"Отмена" style:(UIAlertActionStyleCancel) handler:nil];
    UIAlertAction* editing = [UIAlertAction actionWithTitle:@"Редактировать" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        self.isEditing = !self.isEditing;
        if (self.editing == NO) {
            [self.navigationController setToolbarHidden:YES animated:YES];
        } else {
            [self.navigationController setToolbarHidden:NO animated:YES];
            self.tempObjectArray = [NSMutableArray array];
        }
        [self.tableView setEditing:self.isEditing animated:YES];
        
    }];
    
    UIAlertAction* clear = [UIAlertAction actionWithTitle:@"Отчистить историю" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self allertForDelete];
    }];
    
    [ac addAction:editing];
    [ac addAction:clear];
    [ac addAction:aa];
    
    [self presentViewController:ac animated:YES completion:nil];
}

-(void)allertForDelete{
    UIAlertController* ac2 = [UIAlertController alertControllerWithTitle:@"Очистить историю?" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction* aa = [UIAlertAction actionWithTitle:@"Отмена" style:(UIAlertActionStyleCancel) handler:nil];
    UIAlertAction* clear = [UIAlertAction actionWithTitle:@"Да" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [[DataManager sharedManager] deleteHistory];
        [self.tableView reloadData];
    }];
    
    [ac2 addAction:clear];
    [ac2 addAction:aa];
    
    [self presentViewController:ac2 animated:YES completion:nil];
}
#pragma mark -  Actions UIBarButtonItem
-(void)actionExport:(UIBarButtonItem*)sender{
    
    NSMutableArray* temp = [NSMutableArray array];
    NSArray* array = nil;
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd-MM-yyyy HH:mm"];
    
    if (self.tempObjectArray.count != 0 && self.tempObjectArray) {
        for (HistoryPost* post in self.tempObjectArray) {
            NSString* test = post.value;
            NSString* string = [NSString stringWithFormat:@"text -%@\ndate of creation -  %@", test, [df stringFromDate:post.dateOfCreation]];
            [temp addObject:string];
        }
        
        array = [NSArray arrayWithArray:temp];
        NSLog(@"%@", array);
        UIActivityViewController* avc = [[UIActivityViewController alloc] initWithActivityItems:array applicationActivities:nil];
        //avc.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
        [self presentViewController:avc animated:YES completion:nil];

    }
}
-(void)actionDelete:(UIBarButtonItem*)sender{
    
    if (self.tempObjectArray.count != 0 && self.tempObjectArray) {
        for (HistoryPost* post in self.tempObjectArray) {
            [[DataManager sharedManager].persistentContainer.viewContext deleteObject:post];
        }
        [[DataManager sharedManager] saveContext];
        [self.tempObjectArray removeAllObjects];
        [self.tableView reloadData];
    }
}

-(void)actionCancelEditing:(UIBarButtonItem*)sender{
    self.isEditing = !self.isEditing;

    [self.navigationController setToolbarHidden:YES animated:YES];
    [self.tableView setEditing:self.isEditing animated:YES];
    [self.tableView reloadData];
}

#pragma mark - PopUpForCameraOrGalleryDelegate
- (void) presentCamera{
    QRViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"cameraController"];
    CATransition *transition = [[CATransition alloc] init];
    transition.duration = 0.3;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.view.window.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController pushViewController:vc animated:NO];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"popUpForCamera"]) {
        PopUpForCameraOrGallery* vc = segue.destinationViewController;
        vc.delegate = self;
        //vc.fromMenu = YES;
    }
}
@end
