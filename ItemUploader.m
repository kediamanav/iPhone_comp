//
//  ItemUploader.m
//  sticky
//
//  Created by Manav Kedia on 16/12/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import "ItemUploader.h"
#import "AppDelegate.h"

@interface ItemUploader ()
@property (nonatomic, readwrite, strong) Items* item;
@end


@implementation ItemUploader
@synthesize delegate = _delegate;
@synthesize item = _item;
@synthesize item_name = _item_name;
@synthesize user_name = _user_name;
@synthesize success = _success;

#pragma mark - Life Cycle

- (id)initWithItems:(Items *)userItem delegate:(id<ItemUploaderDelegate>) theDelegate {
    
    if (self = [super init]) {
        self.delegate = theDelegate;
        self.item = userItem;
        self.item_name = _item.item_name;
        self.user_name = _item.user_name;
        self.success = false;
    }
    return self;
}

/* To recover the managed context object from the app delegate*/
- (NSManagedObjectContext *)managedObjectContext{
    NSManagedObjectContext *context = nil;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = delegate.coreDataHelper.managedObjectContext;
    return context;
}

-(void)main{
    @autoreleasepool {
        
            NSLog(@"Inside the threaded function");
        
            //Creating the key-value pair arrays to hold the post data
            NSArray *keys = [[NSArray alloc] initWithObjects:@"user_name",@"item_name",@"item_DOB",@"item_lastTracked",@"item_description",@"item_eLeashRange",@"item_isLost",@"item_eLeashOn",@"item_macAddress", nil];
            NSArray *vals = [[NSArray alloc] initWithObjects:_item.user_name,_item.item_name, _item.item_DOB, _item.item_lastTracked, _item.item_description, _item.item_eLeashRange, _item.item_isLost, _item.item_eLeashOn , _item.item_macAddress, nil];
            
            // NSString *post =[[NSString alloc] initWithFormat:@"user_name=%@&item_name=%@&item_DOB=%@&item_lastTracked=%@&item_description=%@&item_eLeashRange=%ld&item_isLost=%ld&item_eLeashOn=%ld&item_macAddress=%@",_user_name,item_name, dateTimeStamp, dateTimeStamp, item_description, (long)range, (long)isLost, (long)eLeashOn, _macAddress];
            //NSLog(@"PostData: %@",post);
            //NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            //NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
            
            NSURL *url=[NSURL URLWithString:@"http://localhost/~kediamanav/login/addUserItem"];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:url];
            [request setHTTPMethod:@"POST"];
            
            NSMutableData *body = [NSMutableData data];
            
            NSString *boundary = @"---------------------------14737809831466499882746641449";
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
            [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
            
            //Upload image only if the user has selected something, i.e the aplha of the image has changed
            if(_item.item_picture != nil){
                //Imagedata file
                NSData *imageData = _item.item_picture;
                
                NSString *imageName= _item.user_name;
                imageName = [imageName stringByAppendingString:@"_"];
                imageName = [imageName stringByAppendingString:_item.item_name];
                
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: attachment; name=\"imageFile\"; filename=\"%@.jpg\"\r\n", imageName] dataUsingEncoding:NSASCIIStringEncoding]];
                [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[NSData dataWithData:imageData]];
                [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            }
            // Post data parameters
            for(int i=0;i<[keys count];i++){
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSASCIIStringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [keys objectAtIndex:i]] dataUsingEncoding:NSASCIIStringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"%@",[vals objectAtIndex:i]] dataUsingEncoding:NSASCIIStringEncoding]];
                [body appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
            }
            
            //[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            //[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            //[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:body];
            NSLog(@"Body is set");
        
            NSError *error = nil;
            NSHTTPURLResponse *response = nil;
            
            @try {
                NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                
                NSLog(@"Response code: %ld", (long)[response statusCode]);
                if ([response statusCode] >=200 && [response statusCode] <300)
                {
                    NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
                    NSLog(@"Response ==> %@", responseData);
                    
                    SBJsonParser *jsonParser = [SBJsonParser new];
                    NSDictionary *jsonData = (NSDictionary *) [jsonParser objectWithString:responseData error:nil];
                    NSLog(@"%@",jsonData);
                    NSInteger success = [(NSNumber *) [jsonData objectForKey:@"success"] integerValue];
                    NSLog(@"%ld",(long)success);
                    if(success == 1)
                    {
                        NSLog(@"Beacon successfully added to global database");
                        self.success = true;
                    }
                    else{
                        NSString *error_msg = (NSString *) [jsonData objectForKey:@"error_message"];
                        NSLog(@"Beacon could not be added to global database: %@",error_msg);
                    }
                    
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

                }
                else {
                    if (error)
                        NSLog(@"Error: %@", error);
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                }
                
            }
            @catch (NSException * e) {
                NSLog(@"Beacon could not be added. Exception: %@", e);
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            }
                
        
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(itemUploadDidFinish:) withObject:self waitUntilDone:NO];
        
            /*AFHTTPRequestOperation *datasource_download_operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            [datasource_download_operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSData *datasource_data = (NSData *)responseObject;
                
                NSString *responseData = [[NSString alloc]initWithData:datasource_data encoding:NSUTF8StringEncoding];
                NSLog(@"Response ==> %@", responseData);
                
                SBJsonParser *jsonParser = [SBJsonParser new];
                NSDictionary *jsonData = (NSDictionary *) [jsonParser objectWithString:responseData error:nil];
                NSLog(@"%@",jsonData);
                NSInteger success = [(NSNumber *) [jsonData objectForKey:@"success"] integerValue];
                NSLog(@"%ld",(long)success);
                if(success == 1)
                {
                    NSLog(@"Beacon successfully added to global database");
                }
                else{
                    NSString *error_msg = (NSString *) [jsonData objectForKey:@"error_message"];
                    NSLog(@"Beacon could not be added to global database: %@",error_msg);
                }
                
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error){
                NSLog(@"Beacon could not be added to global database: %@",error);
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            }];
            NSLog(@"Before addItem operation");
            [self.pendingOperations.downloadQueue addOperation:datasource_download_operation];
            NSLog(@"After calling addItem operation");
        */
    }
}

@end
