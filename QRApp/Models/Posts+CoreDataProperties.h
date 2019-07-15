//
//  Posts+CoreDataProperties.h
//  QRApp
//
//  Created by Сергей Семин on 16/07/2019.
//  Copyright © 2019 Сергей Семин. All rights reserved.
//
//

#import "Posts+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Posts (CoreDataProperties)

+ (NSFetchRequest<Posts *> *)fetchRequest;


@end

NS_ASSUME_NONNULL_END
