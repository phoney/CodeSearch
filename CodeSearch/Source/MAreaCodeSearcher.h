//
//  MAreaCodeSearcher.h
//  CodeSearch
//
//  Created by Brian Stern on 10/8/15.
//  Copyright © 2015 PhoneyDeveloper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAreaCodeSearcher : NSObject

@property (strong, nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;

-(instancetype)initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

-(NSArray*)searchResultsForSearchString:(NSString*)searchText;


@end
