//
//  AddBeaconViewController.h
//  sticky
//
//  Created by Manav Kedia on 15/10/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <CoreData/CoreData.h>
#include "SBJson.h"

@interface AddBeaconViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tfRange;
@property (weak, nonatomic) IBOutlet UIStepper *rangeCounter;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property NSString *user_name;
@property NSString *macAddress;

- (IBAction)counterPressed:(id)sender;
- (IBAction)addButtonPressed:(id)sender;

@end
