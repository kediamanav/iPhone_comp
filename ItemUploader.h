//
//  ItemUploader.h
//  sticky
//
//  Created by Manav Kedia on 16/12/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Items.h"
#include "SBJson.h"

@protocol ItemUploaderDelegate;

@interface ItemUploader : NSOperation

@property NSString *item_name;
@property NSString *user_name;
@property BOOL success;

@property (nonatomic, assign) id <ItemUploaderDelegate> delegate;

@property (nonatomic, readonly, strong) Items *item;

- (id)initWithItems:(Items *)userItem delegate:(id<ItemUploaderDelegate>) theDelegate;

@end

@protocol ItemUploaderDelegate <NSObject>
- (void)itemUploadDidFinish:(ItemUploader *)uploader;
@end

