//
//  PhotoRecord.m
//  sticky
//
//  Created by Manav Kedia on 15/12/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import "PhotoRecord.h"

@implementation PhotoRecord

@synthesize name = _name;
@synthesize image = _image;
@synthesize imageData = _imageData;
@synthesize URL = _URL;
@synthesize hasImage = _hasImage;
@synthesize failed = _failed;
@synthesize itemImage  = _itemImage;
@synthesize loadFromLocal  = _loadFromLocal;


- (BOOL)hasImage {
    return _image != nil;
}

- (BOOL)isFailed {
    return _failed;
}

-(BOOL) hasPicture{
    return _itemImage;
}

-(BOOL) hasLocal{
    return _loadFromLocal;
}

@end
