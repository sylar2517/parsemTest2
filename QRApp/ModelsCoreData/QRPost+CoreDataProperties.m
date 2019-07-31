//
//  QRPost+CoreDataProperties.m
//  QRApp
//
//  Created by Сергей Семин on 18/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//
//

#import "QRPost+CoreDataProperties.h"

@implementation QRPost (CoreDataProperties)

+ (NSFetchRequest<QRPost *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"QRPost"];
}

@dynamic dateOfCreation;
@dynamic data;
@dynamic type;
@dynamic value;

@end
