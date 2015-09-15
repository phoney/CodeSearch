//
//  AppDelegate.m
//  CodeSearch
//
//  Created by Brian Stern on 9/14/15.
//  Copyright © 2015 PhoneyDeveloper. All rights reserved.
//

#import "AppDelegate.h"
#import "MDataStore.h"

//#define BUILD_STORE 1

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
#if BUILD_STORE
	[self buildDataStore];
#endif
	
	[self listObjects];

	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	// Saves changes in the application's managed object context before the application terminates.
	[self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.example.CodeSearch" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(NSURL*)storeURL
{
#if !defined(BUILD_STORE)
	NSURL *storeURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"CodeSearch" ofType:@"sqlite"]];
#else
	NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CodeSearch.sqlite"];
#endif
	
	return storeURL;
}

-(NSDictionary*)persistentStoreOptions
{
	NSDictionary* options = nil;
	// The default journal mode is WAL, which requires an
	// accessory file created by sqlite. This isn't compatible with
	// a read-only file stored in the app bundle. Setting the journal mode
	// to DELETE doesn't require the journal file. If the sqlite file
	// were copied to a writable location this wouldn't be required.
	// The journal mode needs to be set both when creating the db and
	// when opening it later for reading.
#if !defined(BUILD_STORE)
	options = @{ NSReadOnlyPersistentStoreOption : @YES,
				 NSSQLitePragmasOption : @{@"journal_mode" : @"DELETE"} };
#else 
	options = @{ NSSQLitePragmasOption : @{@"journal_mode" : @"DELETE"} };
#endif

	return options;
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CodeSearch" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSError *error = nil;
	NSURL* storeURL = self.storeURL;
	NSDictionary* options = self.persistentStoreOptions;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Utilities

+(AppDelegate*)applicationDelegate {
	return (AppDelegate*)UIApplication.sharedApplication.delegate;
}

-(void)buildDataStore
{
	NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CodeSearch.sqlite"];
	NSLog(@"Building Data Store at %@", storeURL);
	MDataStore* dataStore = [[MDataStore alloc] initWithMOC:self.managedObjectContext];
	[dataStore buildDataStore];
	
	abort();	// This is all we do
}

-(void)listObjects
{
	MDataStore* dataStore = [[MDataStore alloc] initWithMOC:self.managedObjectContext];
	[dataStore listObjects];
}


@end
