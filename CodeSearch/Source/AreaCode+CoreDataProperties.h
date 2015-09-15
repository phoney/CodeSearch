//
//  AreaCode+CoreDataProperties.h
//  CodeSearch
//
//  Created by Brian Stern on 9/14/15.
//  Copyright © 2015 PhoneyDeveloper. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "AreaCode.h"

NS_ASSUME_NONNULL_BEGIN

@interface AreaCode (CoreDataProperties)

@property (nonatomic) int32_t areaCode;
@property (nullable, nonatomic, retain) NSString *areaCodeString;
@property (nullable, nonatomic, retain) NSString *location;

@end

NS_ASSUME_NONNULL_END
