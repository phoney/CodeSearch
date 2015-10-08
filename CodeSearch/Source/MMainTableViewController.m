//
//  MMainTableViewController.m
//  CodeSearch
//
//  Created by Brian Stern on 9/15/15.
//  Copyright © 2015 PhoneyDeveloper. All rights reserved.
//
//  Displays the list of all area codes.

#import <CoreData/CoreData.h>
#import "MMainTableViewController.h"
#import "MSearchResultsController.h"
#import "MAreaCodeSearcher.h"
#import "MResultCell.h"
#import "AppDelegate.h"

@interface MMainTableViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (strong, nonatomic) MSearchResultsController* resultsController;
@property (strong, nonatomic) UISearchController* searchController;
@property (strong, nonatomic) MAreaCodeSearcher* areaCodeSearcher;

@end

@implementation MMainTableViewController

-(void)viewDidLoad
{
	[super viewDidLoad];
	
	self.areaCodeSearcher = [[MAreaCodeSearcher alloc] initWithManagedObjectContext:AppDelegate.applicationDelegate.managedObjectContext];

	_resultsController = [self.storyboard instantiateViewControllerWithIdentifier:@"ResultsController"];
	_searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsController];
	self.searchController.searchResultsUpdater = self;
	[self.searchController.searchBar sizeToFit];
	self.tableView.tableHeaderView = self.searchController.searchBar;
	
	self.searchController.delegate = self;
	self.searchController.searchBar.delegate = self;

	// This makes the results controller place itself correctly relative to this view controller
	self.definesPresentationContext = YES;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id<NSFetchedResultsSectionInfo> sectionInfo = [[self.areaCodeSearcher.fetchedResultsController sections] objectAtIndex:section];
	return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	MResultCell *cell = (MResultCell*)[self.tableView dequeueReusableCellWithIdentifier:kResultCellReuseIdentifier forIndexPath:indexPath];
	
	cell.areaCode = [self.areaCodeSearcher.fetchedResultsController objectAtIndexPath:indexPath];
	
	return cell;
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
	NSString*	searchText = searchController.searchBar.text;
	searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	NSArray*	results = [self.areaCodeSearcher searchResultsForSearchString:searchText];
	
	// Update the search results table
	self.resultsController.filteredResults = results;
}


@end
