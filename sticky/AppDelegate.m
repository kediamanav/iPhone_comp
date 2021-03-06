//
//  AppDelegate.m
//  sticky
//
//  Created by Manav Kedia on 08/10/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import "AppDelegate.h"
#import "Items.h"
#include "Users.h"
#include "mainTableViewController.h"

@implementation AppDelegate

@synthesize pendingOperations = _pendingOperations;

#define debug 0

- (NSManagedObjectContext *)getManagedObjectContext{
    NSLog(@"Here here");
    return _coreDataHelper.managedObjectContext;
}

- (CoreDataHelper*)cdh {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (!_coreDataHelper) {
        _coreDataHelper = [CoreDataHelper new];
        [_coreDataHelper setupCoreData];
        NSLog(@"Coredata setup");
    }
    return _coreDataHelper;
}


-(Users *) checkIfUserLoggedIn{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Users"];
    
    /* For conditional fetching*/
    //NSPredicate *filter = [NSPredicate predicateWithFormat:@"user_name = 'kediamanav'"];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"user_loggedin == %d",[[NSNumber numberWithInt:1] intValue]];
    [request setPredicate:filter];
    
    NSArray *fetchedObjects = [_coreDataHelper.managedObjectContext executeFetchRequest:request error:nil];
    
    for(Users *user in fetchedObjects){
        NSLog(@"password:%@, email:%@, username:%@",user.user_password,user.user_email,user.user_name);
        return user;
    }
    return nil;
}

-(void) checkForModifiedItems{
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Items"];
    
    // For conditional fetching
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"item_modified == %d",[[NSNumber numberWithInt:1] intValue]];
    [fetchRequest setPredicate:filter];
    
    NSArray *fetchedObjects = [_coreDataHelper.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    for(Items *item in fetchedObjects){
        //This function is supposed to handle both add and update
        //Write php part to handle updates, i.e. modify the entire row if the item exists before with the value being changed
        
        [self startItemUploading:item];
    }
}

#pragma mark -Lazy initialization

- (PendingUploads *)pendingOperations {
    if (!_pendingOperations) {
        _pendingOperations = [[PendingUploads alloc] init];
    }
    return _pendingOperations;
}

- (void)startItemUploading:(Items *)item {
    ItemUploader *itemUploader = [[ItemUploader alloc] initWithItems:item delegate:self];
    [self.pendingOperations.uploadQueue addOperation:itemUploader];
}

- (void)itemUploadDidFinish:(ItemUploader *)uploader {
    
    NSString *item_name = uploader.item_name;
    NSString *user_name = uploader.user_name;
    BOOL success = uploader.success;
    
    //Update here that the item is no longer modified
    if(success==true){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Items"];

        // For conditional fetching
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"(user_name=%@) AND (item_name=%@)",user_name,item_name];
        [request setPredicate:filter];

        NSError *error = nil;
        Items *item = nil;
        item = [[_coreDataHelper.managedObjectContext executeFetchRequest:request error:&error] lastObject];

        if(error){
            NSLog(@"Can't execute fetch request! %@ %@", error, [error localizedDescription]);
        }
        if(item){
            item.item_modified = [NSNumber numberWithInt:(int)0];
            [_coreDataHelper saveContext];
        }
    }
}


#pragma mark - Other functions
-(void)demo{
    /*
     **  Method to add to existing database
    */
    /*NSArray *newItemNames = [NSArray arrayWithObjects:@"Apples", @"Milk", @"Bread", @"Cheese", @"Sausages", @"Butter",@"Orange Juice", @"Cereal", @"Coffee", @"Eggs", @"Tomatoes", @"Fish",nil];
    
    for (NSString *newItemName in newItemNames) {
        Items *newItem =
        [NSEntityDescription insertNewObjectForEntityForName:@"Items" inManagedObjectContext:_coreDataHelper.managedObjectContext];
        newItem.item_name = newItemName;
        NSLog(@"Inserted New Managed Object for '%@'", newItem.item_name);
    }*/
    
    /*
     **  Method to fetch all the objects from the database
    */
    
    
    NSFetchRequest *request1 = [NSFetchRequest fetchRequestWithEntityName:@"Users"];
    NSFetchRequest *request2 = [NSFetchRequest fetchRequestWithEntityName:@"Items"];
    
    //For sorting the data based on an item_key
    //NSSortDescriptor *sort =[NSSortDescriptor sortDescriptorWithKey:@"item_name" ascending:YES];
    //[request setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    //For conditional fetching
    //NSPredicate *filter = [NSPredicate predicateWithFormat:@"item_name!=%@",@"Coffee"];
    //[request setPredicate:filter];
     
    NSArray *fetchedObjects1 = [_coreDataHelper.managedObjectContext executeFetchRequest:request1 error:nil];
    NSArray *fetchedObjects2 = [_coreDataHelper.managedObjectContext executeFetchRequest:request2 error:nil];
    
    for(Items *item in fetchedObjects2){
        NSLog(@"Fetched Object = %@",item.item_name);
        //For deleting an object
        [_coreDataHelper.managedObjectContext deleteObject:item];
    }
    
    for(Users *user in fetchedObjects1){
        NSLog(@"Fetched Object = %@",user.user_name);
        //For deleting an object
        [_coreDataHelper.managedObjectContext deleteObject:user];
    }
    
    [_coreDataHelper saveContext];
}

#pragma mark - AppDelegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if(debug==1){
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    [self cdh];
    //Call this to erase all the item and user data
    [self demo];
    
    
    Users *user=[self checkIfUserLoggedIn];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UINavigationController *homeScreenVC;
    if(user==nil){
        homeScreenVC = [storyboard instantiateInitialViewController];
        mainTableViewController *mainScreen = [storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
        [homeScreenVC setViewControllers:[NSArray arrayWithObjects:mainScreen, nil] animated:NO];
    }
    else{
        homeScreenVC = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"MainNVI"];
        NSLog(@"HERE: %@", user.user_name);
        mainTableViewController *mainScreen = [storyboard instantiateViewControllerWithIdentifier:@"mainTableViewController"];
        mainScreen.user_name = [[NSString alloc] initWithFormat:@"%@", user.user_name];
        mainScreen.loadFromLocal = 1;
        [homeScreenVC setViewControllers:[NSArray arrayWithObjects:mainScreen, nil] animated:NO];

    }
    
    self.window.rootViewController = homeScreenVC;
    [self.window makeKeyAndVisible];
    
    [self checkForModifiedItems];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    if(debug==1){
        NSLog(@"Running %@ '%@'",self.class, NSStringFromSelector(_cmd));
    }
    [self setPendingOperations:nil];
    [[self cdh] saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
# pragma mark - Core data saveContext
 
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
 
 
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MyStore" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MyStore.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        /*NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
*/

@end
