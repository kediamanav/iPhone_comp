//
//  scanBeaconViewController.h
//  sticky
//
//  Created by Manav Kedia on 08/10/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddBeaconViewController.h"

@interface scanBeaconViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
- (IBAction) unwindToScanBeacon:(UIStoryboardSegue *) segue;
@property NSString *user_name;
@end
