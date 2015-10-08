//
//  MAreaCodeSearcher.m
//  CodeSearch
//
//  Created by Brian Stern on 10/8/15.
//  Copyright © 2015 PhoneyDeveloper. All rights reserved.
//
//	Data Model class that does the filtering for the Search Results Controller.

#import <CoreData/CoreData.h>
#import "MAreaCodeSearcher.h"

@interface MAreaCodeSearcher () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation MAreaCodeSearcher

-(instancetype)initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
	if ((self = [super init])) {
		self.managedObjectContext = managedObjectContext;
		
		// Load all the area codes
		NSError* err;
		if (![self.fetchedResultsController performFetch:&err]) {
			NSLog(@"Couldn't fetch %@", err);
		}
	}
	return self;
}

#pragma mark - Search core data

-(NSArray*)searchResultsForSearchString:(NSString*)searchText
{
	// Search for areaCode if the searchText is a number or
	// search for location or country if it isn't a number
	NSPredicate* predicate = nil;
	if (searchText.integerValue != 0) {
		// It's a number
		predicate = [self predicateForAreaCode:searchText];
	} else {
		// Just plain text
		predicate = [self predicateForLocationOrCountry:searchText];
	}
	
	NSFetchRequest* fetchRequest = [self fetchRequestWithPredicate:predicate];
	
	NSError*	err = nil;
	NSArray*	results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&err];

	return results;
}

-(NSFetchRequest*)fetchRequestWithPredicate:(NSPredicate*)predicate
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"AreaCode" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"areaCode" ascending:YES];
	[fetchRequest setSortDescriptors:@[sort]];
	[fetchRequest setFetchBatchSize:20];
	
	return fetchRequest;
}

-(NSPredicate*)predicateForAreaCode:(NSString*)searchText
{
	NSInteger low = 0;
	NSInteger high = 1000;
	NSInteger value = searchText.integerValue;
	BOOL exact = NO;
	
	if (value  < 10) {
		// 7
		low = value * 100;
		high = low + 99;
	} else if (value < 100) {
		// 71
		low = value * 10;
		high = low + 9;
	} else {
		// 718
		while (value > 1000) {
			value /= 10;	// ignore digits past the first three
		}
		exact = YES;
	}
	
	NSPredicate* predicate = exact ?
	[NSPredicate predicateWithFormat:@"areaCode == %ld", value] :
	[NSPredicate predicateWithFormat:@"areaCode >= %ld AND areaCode <= %ld", low, high];
	
	return predicate;
}

-(NSPredicate*)predicateForLocationOrCountry:(NSString*)searchText
{
	NSPredicate* predicate = [NSPredicate predicateWithFormat:@"location BEGINSWITH[cd] %@ OR country BEGINSWITH[cd] %@", searchText, searchText];
	
	return predicate;
}

#pragma mark - NSFetchResultsController

- (NSFetchedResultsController *)fetchedResultsController {
 
	if (_fetchedResultsController != nil) {
		return _fetchedResultsController;
	}
 
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"AreaCode" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
 
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"areaCode" ascending:YES];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
	[fetchRequest setFetchBatchSize:20];
 
	_fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	_fetchedResultsController.delegate = self;
 
	return _fetchedResultsController;
}

@end
