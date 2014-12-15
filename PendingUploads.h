//
//  PendingUploads.h
//  sticky
//
//  Created by Manav Kedia on 16/12/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PendingUploads : NSObject

@property (nonatomic, strong) NSOperationQueue *uploadQueue;

@end
