//
//  BeaconTableViewCell.h
//  sticky
//
//  Created by Manav Kedia on 15/10/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeaconTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastTrackedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImage;

@end
