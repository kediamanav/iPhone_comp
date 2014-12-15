//
//  mainTableViewController.h
//  sticky
//
//  Created by Manav Kedia on 08/10/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "beaconClass.h"
#import "BeaconTableViewCell.h"
#import "scanBeaconViewController.h"
#import "SBJson.h"
#include "AppDelegate.h"
#include "Items.h"
#import "PhotoRecord.h"
#import "ImageDownloader.h"
#import "PendingOperations.h"
#import "AFNetworking.h"

@interface mainTableViewController : UITableViewController <ImageDownloaderDelegate>
- (IBAction) unwindToList:(UIStoryboardSegue *) segue;
@property NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSString *user_name;
@property NSInteger loadFromLocal;
@property (nonatomic, strong) PendingOperations *pendingOperations;

@end
