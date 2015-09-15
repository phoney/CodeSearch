//
//  MDataStore.m
//  CodeSearch
//
//  Created by Brian Stern on 9/14/15.
//  Copyright © 2015 PhoneyDeveloper. All rights reserved.
//

#import "MDataStore.h"
#import "AreaCode.h"
#import "AppDelegate.h"

@interface MDataStore ()

@property (nonatomic) NSManagedObjectContext* managedObjectContext;
@property (nonatomic) NSArray* zipcodeData;

@end

@implementation MDataStore

-(instancetype)initWithMOC:(NSManagedObjectContext*)context
{
	if ((self = [super init])) {
		_managedObjectContext = context;
	}
	return self;
}

-(void)buildZipcodeData
{
	self.zipcodeData = @[
		@{@"areaCode" : @"718", @"location" : @"Queens, NY"},
		@{@"areaCode" : @"502", @"location" : @"Georgetown, KY"},
		@{@"areaCode" : @"212", @"location" : @"New York, NY"},
	];
}

-(void)buildDataStore
{
	[self buildZipcodeData];
	[self addObjectsToMOC];
	[self listObjects];
	[self shutdownCoreData];
}

-(void)addObjectsToMOC
{
	NSManagedObjectContext* context = self.managedObjectContext;
	
	[self.zipcodeData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		AreaCode* areaCode = [NSEntityDescription insertNewObjectForEntityForName:@"AreaCode" inManagedObjectContext:context];
		areaCode.areaCode = [[obj objectForKey:@"areaCode"] intValue];
		areaCode.areaCodeString = [obj objectForKey:@"areaCode"];
		areaCode.location = [obj objectForKey:@"location"];
		
		NSError* err;
		if (![context save:&err]) {
			NSLog(@"Couldn't save context %@", err);
		}
	}];
	
}

-(void)listObjects
{
	NSManagedObjectContext* context = self.managedObjectContext;
	NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"AreaCode" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSError* err;
	NSArray* fetchedObjects = [context executeFetchRequest:fetchRequest error:&err];
	
	for (NSManagedObject* info in fetchedObjects) {
		NSLog(@"Area Code: %@, Area Code: %@, Location: %@", [info valueForKey:@"areaCode"], [info valueForKey:@"areaCodeString"], [info valueForKey:@"location"]);
	}
}

-(void)shutdownCoreData
{
	[self.managedObjectContext reset];
	NSPersistentStoreCoordinator* persistentStoreCoordinator = AppDelegate.applicationDelegate.persistentStoreCoordinator;
	
	NSError *err;
	for (NSPersistentStore *store in persistentStoreCoordinator.persistentStores) {
		BOOL removed = [persistentStoreCoordinator removePersistentStore:store error:&err];
		
		if (!removed) {
			NSLog(@"Unable to remove persistent store: %@", err);
		}
	}
}

@end
