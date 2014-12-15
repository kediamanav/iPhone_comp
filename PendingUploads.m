//
//  PendingUploads.m
//  sticky
//
//  Created by Manav Kedia on 16/12/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import "PendingUploads.h"

@implementation PendingUploads

@synthesize uploadQueue = _uploadQueue;

- (NSOperationQueue *)uploadQueue {
    if (!_uploadQueue) {
        _uploadQueue = [[NSOperationQueue alloc] init];
        _uploadQueue.name = @"Upload Queue";
        //_downloadQueue.maxConcurrentOperationCount = 1;
    }
    return _uploadQueue;
}

@end
