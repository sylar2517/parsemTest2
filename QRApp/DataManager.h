//
//  DataManager.h
//  QRApp
//
//  Created by Сергей Семин on 29/06/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
NS_ASSUME_NONNULL_BEGIN

@interface DataManager : NSObject
@property (readonly, strong) NSPersistentContainer *persistentContainer;

+ (DataManager*) sharedManager;

- (void)saveContext;
-(void) deleteAllObject;
@end

NS_ASSUME_NONNULL_END
