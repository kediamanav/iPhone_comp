//
//  beaconClass.h
//  sticky
//
//  Created by Manav Kedia on 08/10/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface beaconClass : NSObject
@property NSString *name;
@property NSString *details;
@property NSString *macAddress;
@property NSNumber *e_distance;
@property NSString *lastTracked;
@property BOOL eleash;
@property NSDate *dateOfAddition;
@property NSData *imageData;
@property NSString *imageURL;
@end
