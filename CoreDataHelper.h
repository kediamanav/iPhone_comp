//
//  CoreDataHelper.h
//  sticky
//
//  Created by Manav Kedia on 23/10/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CoreDataHelper : NSObject

@property (nonatomic, readonly) NSManagedObjectContext       *managedObjectContext;
@property (nonatomic, readonly) NSManagedObjectModel         *managedObjectModel;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly) NSPersistentStore            *persistentStore;

- (void)setupCoreData;
- (void)saveContext;
//- (NSURL *)applicationDocumentsDirectory;
@end