//
//  PhotoRecord.h
//  sticky
//
//  Created by Manav Kedia on 15/12/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoRecord : NSObject
@property (nonatomic, strong) NSString *name;  // To store the name of image
@property (nonatomic, strong) UIImage *image; // To store the actual image
@property (nonatomic, strong) NSData *imageData; // To store the actual image
@property (nonatomic, strong) NSURL *URL; // To store the URL of the image
@property (nonatomic, readonly) BOOL hasImage; // Return YES if image is downloaded.
@property (nonatomic, getter = isFailed) BOOL failed; // Return Yes if image failed to be downloaded
@property (nonatomic, getter = hasPicture) BOOL itemImage; // Return Yes if image is saved for this
@property (nonatomic, getter = hasLocal) BOOL loadFromLocal; // Return Yes if image to be loaded from local


@end
