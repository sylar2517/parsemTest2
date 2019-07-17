//
//  HistoryPost+CoreDataProperties.m
//  QRApp
//
//  Created by Сергей Семин on 18/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//
//

#import "HistoryPost+CoreDataProperties.h"

@implementation HistoryPost (CoreDataProperties)

+ (NSFetchRequest<HistoryPost *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"HistoryPost"];
}

@dynamic dateOfCreation;
@dynamic picture;
@dynamic type;
@dynamic value;

@end
