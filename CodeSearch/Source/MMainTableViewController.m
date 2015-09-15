//
//  MMainTableViewController.m
//  CodeSearch
//
//  Created by Brian Stern on 9/15/15.
//  Copyright © 2015 PhoneyDeveloper. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "MMainTableViewController.h"
#import "MSearchResultsController.h"
#import "MResultCell.h"
#import "AppDelegate.h"

@interface MMainTableViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) MSearchResultsController* resultsController;
@property (strong, nonatomic) UISearchController* searchController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation MMainTableViewController

-(void)viewDidLoad
{
	[super viewDidLoad];
	
	self.managedObjectContext = AppDelegate.applicationDelegate.managedObjectContext;

	_resultsController = [self.storyboard instantiateViewControllerWithIdentifier:@"ResultsController"];
	_searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsController];
	self.searchController.searchResultsUpdater = self;
	[self.searchController.searchBar sizeToFit];
	self.tableView.tableHeaderView = self.searchController.searchBar;
	
	self.searchController.delegate = self;
	self.searchController.searchBar.delegate = self;

	// This makes the results controller place itself correctly relative to this view controller
	self.definesPresentationContext = YES;

	// Load all the area codes
	NSError* err;
	if (![self.fetchedResultsController performFetch:&err]) {
		NSLog(@"Couldn't fetch %@", err);
	}
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	MResultCell *cell = (MResultCell*)[self.tableView dequeueReusableCellWithIdentifier:kResultCellReuseIdentifier forIndexPath:indexPath];
	
	cell.areaCode = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	return cell;
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
	NSString*	searchText = searchController.searchBar.text;
	searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
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
	
	// Update the search results table
	self.resultsController.filteredResults = results;
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
