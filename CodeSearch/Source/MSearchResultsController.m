//
//  MSearchResultsController.m
//  CodeSearch
//
//  Created by Brian Stern on 9/15/15.
//  Copyright © 2015 PhoneyDeveloper. All rights reserved.
//

#import "MSearchResultsController.h"
#import "MResultCell.h"

@implementation MSearchResultsController

-(void)setFilteredResults:(NSArray *)filteredResults
{
	_filteredResults = [filteredResults copy];
	[self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.filteredResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	MResultCell *cell = (MResultCell*)[self.tableView dequeueReusableCellWithIdentifier:kResultCellReuseIdentifier forIndexPath:indexPath];
	
	cell.areaCode = [self.filteredResults objectAtIndex:indexPath.row];
	
	return cell;
}

@end
