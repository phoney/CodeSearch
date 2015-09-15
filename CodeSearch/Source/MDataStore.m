//
//  MDataStore.m
//  CodeSearch
//
//  Created by Brian Stern on 9/14/15.
//  Copyright © 2015 PhoneyDeveloper. All rights reserved.
//
// This class builds a readonly sqlite data store that contains the area code
// information from the npa_report.csv file. This code only needs to be run during development
// one time to generate the sqlite file that is added to the project and read in
// during normal app operation.

#import "MDataStore.h"
#import "AreaCode.h"
#import "AppDelegate.h"
#import "CHCSVParser.h"

#define kAreaCodeCSVFile @"npa_report.csv"
// This CSV file has 33 columns. I'm not interested in most of them.
// It has 801 rows with around 400 area codes that are interesting.
// See AreaCodeDatabaseDefinitions.xls for the descriptions of all the columns.
// The CSV parser returns an array of arrays so each column is found in the
// row array.

#define kAreaCodeColumn 0 /* The NPA or Area Code */
#define kAssignedColumn 5 /* Is the NPA assigned for use (Yes/No) */
#define kLocationColumn 8 /* The geographic location to which the code is assigned (AL, TX, Manitoba, etc.) */
#define kCountryColumn 9 /* The country to which the assignment was made (US, CANADA, BAHAMAS, etc.) */
#define kTimeZoneColumn 20 /* The predominant time zone (s) for this NPA (A - Atlantic; E- Eastern; C - Central; P - Pacific; etc)*/
#define kSpecialColumn 14 /* This column is supposed to be BLANK but it holds a description for some special area codes, which are quoted */
@interface MDataStore ()

@property (nonatomic) NSManagedObjectContext* managedObjectContext;
@property (nonatomic) NSArray* areacodeData;

@end

@implementation MDataStore

-(instancetype)initWithMOC:(NSManagedObjectContext*)context
{
	if ((self = [super init])) {
		_managedObjectContext = context;
	}
	return self;
}

-(void)buildAreaCodeData
{
	NSURL*	areaCodeCSVFile = [[NSBundle mainBundle] URLForResource:kAreaCodeCSVFile withExtension:nil];
	NSArray* list = [NSArray arrayWithContentsOfCSVURL:areaCodeCSVFile];
//	NSLog(@"%@", list);
	
	NSMutableArray* areacodeData = [NSMutableArray array];
	
	for (NSArray* row in list) {
		if (row.count < kTimeZoneColumn)
			continue;
		BOOL assigned = [row[kAssignedColumn] isEqualToString:@"Yes"];
		if (assigned ) {
			// TODO: improve filtering so some area codes that really aren't used aren't added
			NSString* areaCode = row[kAreaCodeColumn];
			NSString* location = row[kLocationColumn];
			NSString* country = row[kCountryColumn];
			
			// Fix up some oddball records
			if ([location isEqualToString:@"NANP AREA"]) {
				NSString* newLocation = row[kSpecialColumn];
				if (newLocation != nil) {
					location = [newLocation stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];	// trim double quotes
				}
			}
			
			// Convert two letter state names to full state names
			if (location.length == 2) {
				NSString*	newLocation = [self.stateDictionary objectForKey:location];
				if (newLocation) {
					location = newLocation;
				} else {
					NSLog(@"BAD LOCATION %@", location);
				}
			} else {
				location = [location capitalizedString];
			}

			// Convert country US to something else like USA or United States
			if ([country isEqualToString:@"US"]) {
				country = @"USA";
			} else {
				// Convert all upper case country names to leading caps, PUERTO RICO -> Puerto Rico
				country = [country capitalizedString];
			}
			
			NSDictionary* rowData = @{ @"areaCode" : areaCode, @"location" : location,   @"country" : country };
			
			[areacodeData addObject:rowData];
		}
	}
	
	self.areacodeData = [areacodeData copy];
}

-(NSDictionary*)stateDictionary
{
	static NSDictionary* states = nil;
	
	if (states == nil) {
		states = @{
				   @"AL" : @"Alabama",
				   @"AK" : @"Alaska",
				   @"AZ" : @"Arizona",
				   @"AR" : @"Arkansas",
				   @"CA" : @"California",
				   @"CO" : @"Colorado",
				   @"CT" : @"Connecticut",
				   @"DE" : @"Deleware",
				   @"DC" : @"District of Columbia",
				   @"FL" : @"Florida",
				   @"GA" : @"Georgia",
				   @"HI" : @"Hawaii",
				   @"ID" : @"Idaho",
				   @"IL" : @"Illinois",
				   @"IN" : @"Indiana",
				   @"IA" : @"Iowa",
				   @"KS" : @"Kansa",
				   @"KY" : @"Kentucky",
				   @"LA" : @"Louisianna",
				   @"ME" : @"Maine",
				   @"MD" : @"Maryland",
				   @"MA" : @"Massachusetts",
				   @"MI" : @"Michigan",
				   @"MN" : @"Minnisota",
				   @"MS" : @"Mississippi",
				   @"MO" : @"Missouri",
				   @"MT" : @"Montana",
				   @"NE" : @"Nebraska",
				   @"NV" : @"Nevada",
				   @"NH" : @"New Hampshire",
				   @"NJ" : @"New Jersey",
				   @"NM" : @"New Mexico",
				   @"NY" : @"New York",
				   @"NC" : @"North Carolina",
				   @"ND" : @"North Dakota",
				   @"OH" : @"Ohio",
				   @"OK" : @"Oklahoma",
				   @"OR" : @"Oregon",
				   @"PA" : @"Pennsylvania",
				   @"RI" : @"Rhode Island",
				   @"SC" : @"South Carolina",
				   @"SD" : @"South Dakota",
				   @"TN" : @"Tennesee",
				   @"TX" : @"Texas",
				   @"UT" : @"Utah",
				   @"VT" : @"Vermont",
				   @"VA" : @"Virginia",
				   @"WA" : @"Washington",
				   @"WV" : @"West Virginia",
				   @"WI" : @"Wisconson",
				   @"WY" : @"Wyoming",

				   @"GU" : @"Guam",
				   @"AS" : @"American Samoa",

				   // There are other abbreviations but I don't think they're used in csv file
				   // See https://en.wikipedia.org/wiki/List_of_U.S._state_abbreviations
				   };
		
	}
	
	return states;
}

-(void)buildDataStore
{
	[self buildAreaCodeData];
	[self addObjectsToMOC];
	[self listObjects];
	[self shutdownCoreData];
}

-(void)addObjectsToMOC
{
	NSManagedObjectContext* context = self.managedObjectContext;
	
	[self.areacodeData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		AreaCode* areaCode = [NSEntityDescription insertNewObjectForEntityForName:@"AreaCode" inManagedObjectContext:context];
		areaCode.areaCode = [[obj objectForKey:@"areaCode"] intValue];
		areaCode.areaCodeString = [obj objectForKey:@"areaCode"];
		areaCode.location = [obj objectForKey:@"location"];
		areaCode.country = [obj objectForKey:@"country"];
		
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
	
	NSLog(@"LIST OF AREA CODE OBJECTS IN THE DATABASE");
	for (NSManagedObject* info in fetchedObjects) {
		NSLog(@"Area Code: %@, Area Code: %@, Location: %@", [info valueForKey:@"areaCode"], [info valueForKey:@"areaCodeString"], [NSString stringWithFormat:@"%@, %@", [info valueForKey:@"location"], [info valueForKey:@"country"]]);
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
