//
//  QRPost+CoreDataProperties.h
//  QRApp
//
//  Created by Сергей Семин on 18/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//
//

#import "QRPost+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface QRPost (CoreDataProperties)

+ (NSFetchRequest<QRPost *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *dateOfCreation;
@property (nullable, nonatomic, retain) NSData *data;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, copy) NSString *value;

@end

NS_ASSUME_NONNULL_END
