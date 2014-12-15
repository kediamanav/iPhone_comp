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

@interface mainTableViewController : UITableViewController
- (IBAction) unwindToList:(UIStoryboardSegue *) segue;
@property NSMutableArray *items;
@property (nonatomic, strong) NSString *user_name;
@property NSInteger *loadFromLocal;
@end
