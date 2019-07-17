//
//  DataManager.m
//  QRApp
//
//  Created by Сергей Семин on 29/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager
+ (DataManager*) sharedManager{
    static DataManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DataManager alloc] init];
    });
    return manager;
}
-(void) deleteAll{
    NSArray* resultArray = [self allObjects];
    for (id object in resultArray) {
        [self.persistentContainer.viewContext deleteObject:object];
    }
    [self.persistentContainer.viewContext save:nil];
   
}

-(void)deleteHistoryScan{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* description = [NSEntityDescription entityForName:@"HistoryPost" inManagedObjectContext:self.persistentContainer.viewContext];
    [request setEntity:description];
    NSError* reqestError = nil;
    NSArray* resultArray = [self.persistentContainer.viewContext executeFetchRequest:request error:&reqestError];
    if (reqestError) {
        NSLog(@"%@", [reqestError localizedDescription]);
    }
    for (id object in resultArray) {
        [self.persistentContainer.viewContext deleteObject:object];
    }
    [self.persistentContainer.viewContext save:nil];
}

-(void)deleteQR{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* description = [NSEntityDescription entityForName:@"QRPost" inManagedObjectContext:self.persistentContainer.viewContext];
    [request setEntity:description];
    NSError* reqestError = nil;
    NSArray* resultArray = [self.persistentContainer.viewContext executeFetchRequest:request error:&reqestError];
    if (reqestError) {
        NSLog(@"%@", [reqestError localizedDescription]);
    }
    for (id object in resultArray) {
        [self.persistentContainer.viewContext deleteObject:object];
    }
    [self.persistentContainer.viewContext save:nil];
}
-(NSArray*)allObjects{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* description = [NSEntityDescription entityForName:@"Posts" inManagedObjectContext:self.persistentContainer.viewContext];
    [request setEntity:description];
    NSError* reqestError = nil;
    NSArray* resultArray = [self.persistentContainer.viewContext executeFetchRequest:request error:&reqestError];
    if (reqestError) {
        NSLog(@"%@", [reqestError localizedDescription]);
    }
    return resultArray;
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"QRApp"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}


@end
