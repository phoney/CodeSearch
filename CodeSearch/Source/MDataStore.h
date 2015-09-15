//
//  MDataStore.h
//  CodeSearch
//
//  Created by Brian Stern on 9/14/15.
//  Copyright © 2015 PhoneyDeveloper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MDataStore : NSObject

-(instancetype)initWithMOC:(NSManagedObjectContext*)context;

-(void)buildDataStore;
-(void)listObjects;

@end
