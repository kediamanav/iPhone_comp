//
//  ImageDownloader.m
//  sticky
//
//  Created by Manav Kedia on 15/12/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import "ImageDownloader.h"

// 1
@interface ImageDownloader ()
@property (nonatomic, readwrite, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readwrite, strong) PhotoRecord *photoRecord;
@end


@implementation ImageDownloader
@synthesize delegate = _delegate;
@synthesize indexPathInTableView = _indexPathInTableView;
@synthesize photoRecord = _photoRecord;

#pragma mark -
#pragma mark - Life Cycle

- (id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageDownloaderDelegate>)theDelegate {
    
    if (self = [super init]) {
        // 2
        self.delegate = theDelegate;
        self.indexPathInTableView = indexPath;
        self.photoRecord = record;
    }
    return self;
}

#pragma mark -
#pragma mark - Downloading image

// 3
- (void)main {
    
    // 4
    @autoreleasepool {
        if(_photoRecord.itemImage==false){
            return;
        }
        if (self.isCancelled)
            return;
        
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:self.photoRecord.URL];
        self.photoRecord.imageData = imageData;
        
        if (self.isCancelled) {
            imageData = nil;
            return;
        }
        
        if (imageData) {
            UIImage *downloadedImage = [UIImage imageWithData:imageData];
            self.photoRecord.image = downloadedImage;
        }
        else {
            self.photoRecord.failed = YES;
        }
        
        imageData = nil;
        
        if (self.isCancelled)
            return;
        
        // 5
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageDownloaderDidFinish:) withObject:self waitUntilDone:NO];
        
    }
}

@end
