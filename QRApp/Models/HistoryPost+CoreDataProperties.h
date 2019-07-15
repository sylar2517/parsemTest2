//
//  HistoryPost+CoreDataProperties.h
//  QRApp
//
//  Created by Сергей Семин on 16/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//
//

#import "HistoryPost+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface HistoryPost (CoreDataProperties)

+ (NSFetchRequest<HistoryPost *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *dateOfCreation;
@property (nullable, nonatomic, retain) NSData *picture;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, copy) NSString *value;

@end

NS_ASSUME_NONNULL_END
