//
//  Users.h
//  sticky
//
//  Created by Manav Kedia on 15/12/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Users : NSManagedObject

@property (nonatomic, retain) NSString * user_email;
@property (nonatomic, retain) NSString * user_name;
@property (nonatomic, retain) NSString * user_password;
@property (nonatomic, retain) NSNumber * user_loggedin;

@end
