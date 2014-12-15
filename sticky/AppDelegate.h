//
//  AppDelegate.h
//  sticky
//
//  Created by Manav Kedia on 08/10/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"
#include "ItemUploader.h"
#include "PendingUploads.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,ItemUploaderDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong, readonly) CoreDataHelper *coreDataHelper;

- (NSManagedObjectContext *)getManagedObjectContext;
@property (nonatomic, strong) PendingUploads *pendingOperations;

/*
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
*/
 
@end
