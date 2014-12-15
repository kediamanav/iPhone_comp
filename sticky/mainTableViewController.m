//
//  mainTableViewController.m
//  sticky
//
//  Created by Manav Kedia on 08/10/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import "mainTableViewController.h"

@interface mainTableViewController ()
@property NSInteger totalItems;
@property NSInteger itemsLoaded;
@end

@implementation mainTableViewController

@synthesize user_name;
@synthesize pendingOperations = _pendingOperations;

/* To recover the managed context object from the app delegate*/
- (NSManagedObjectContext *)managedObjectContext{
    NSManagedObjectContext *context = nil;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = delegate.coreDataHelper.managedObjectContext;
    return context;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _totalItems = 0;
    _itemsLoaded = 0;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_bg.jpg"]];
    self.tableView.backgroundView.alpha = 0.6;
    //Check the username here, passed via segue
    NSLog(@"Username is : %@",self.user_name);
    
    //Allocate the array
    self.items = [[NSMutableArray alloc] init];
    //Call the function to load the array data for the table
    [self loadTableData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) viewDidUnload{
    [self setPendingOperations:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
 **Executed when the user comes back from after the search of beacons
 * so we should again search and see if any new data was added or not
*/
- (IBAction)unwindToList:(UIStoryboardSegue *)seque{
    if(_loadFromLocal==0){
        self.totalItems = 0;
        self.itemsLoaded = 0;
    }
    [self loadTableData];
}

#pragma mark -Lazy initialization

- (PendingOperations *)pendingOperations {
    if (!_pendingOperations) {
        _pendingOperations = [[PendingOperations alloc] init];
    }
    return _pendingOperations;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if(_loadFromLocal ==0 && self.itemsLoaded == self.totalItems){
        _loadFromLocal = 1;
    }
    if([[segue identifier] isEqualToString:@"scanBeaconSegue"]){
        NSLog(@"Prepare for segue: %@", segue.identifier);
        UINavigationController *segueNavigation = [segue destinationViewController];
        scanBeaconViewController *transferViewController = (scanBeaconViewController *)[[segueNavigation viewControllers] objectAtIndex:0];
        transferViewController.user_name = self.user_name;
        NSLog(@"%@", transferViewController.user_name);
    }
}

#pragma mark - Loading from databases

/*
 ** This method is to load the table from local database
 */
- (void) loadFromLocalDatabase{

    /*
     **  Method to fetch all the objects from the database
     */
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Items"];
    
    /* For conditional fetching*/
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"user_name=%@",user_name];
    [request setPredicate:filter];
    
    //Add to persistent store here
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSArray *fetchedObjects = [context executeFetchRequest:request error:nil];
    
    for(Items *item in fetchedObjects){
        NSLog(@"Fetched Object = %@",item.item_name);
        
        beaconClass *item1=[[beaconClass alloc] init];
        item1.name = item.item_name;
        item1.lastTracked = item.item_lastTracked;
        
        NSData *picture_data = item.item_picture;
        PhotoRecord *record = [[PhotoRecord alloc] init];
        //NSLog(@"%@",picture_data);
        if(picture_data==nil){
            //item1.imageData = [UIImage imageNamed:@"item_default.png"];
            record.itemImage = false;
        }
        else{
            item1.imageData = picture_data;
            record.itemImage = true;
            record.loadFromLocal = true;
        }
        [_photos addObject:record];
        record=nil;
        
        [self.items addObject:item1];
        NSLog(@"Name: %@, Last-tracked: %@",item1.name, item1.lastTracked);
    }
    
    NSLog(@"Before table reload");
    [self.tableView reloadData];
    NSLog(@"After table reload");

}

/*
-(void) loadFromGlobalDatabase{
    @try {
        
        if([user_name isEqualToString:@""]) {
            [self alertStatus:@"Not logged in" :@"Error!"];
        } else {
            NSString *post =[[NSString alloc] initWithFormat:@"user_name=%@",user_name];
            NSLog(@"PostData: %@",post);
            
            NSURL *url=[NSURL URLWithString:@"http://localhost/~kediamanav/login/getUserItems"];
            
            NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            
            NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:url];
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:postData];
            
            //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];

            NSError *error = [[NSError alloc] init];
            NSHTTPURLResponse *response = nil;
            NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            NSLog(@"Response code: %ld", (long)[response statusCode]);
            if ([response statusCode] >=200 && [response statusCode] <300)
            {
                NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
                //NSLog(@"Response ==> %@", responseData);
                
                SBJsonParser *jsonParser = [SBJsonParser new];
                NSArray  *itemList = [jsonParser objectWithString:responseData error:NULL];
                
                //NSLog(@"%@",itemList);
                
                for (NSDictionary *item in itemList){
                    
                    // Now add it to the CoreData database also
                    //Add to persistent store here
                    NSManagedObjectContext *context = [self managedObjectContext];
                    Items *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Items" inManagedObjectContext:context];
                    
                    beaconClass *item1=[[beaconClass alloc] init];
                    item1.name = [item objectForKey:@"item_name"];
                    item1.lastTracked = [item objectForKey:@"item_lastTracked"];
                    
                    NSString *pictureURL = [item objectForKey:@"item_picture"];
                    PhotoRecord *record = [[PhotoRecord alloc] init];
                    if(![pictureURL isEqual: [NSNull null]]){
                        record.URL = [NSURL URLWithString:pictureURL];
                        NSLog(@"pictureURL: %@",pictureURL);
                        [_photos addObject:record];
                        record = nil;
                    }
                    
                    item1.imageURL = pictureURL;
                    */
                    /*
                     Extracting images from the server in the difficult way, using base64 encoding
                     NSString *item_data = [item objectForKey:@"item_picture"];
                     //NSLog(@"item_data: %@",item_data);
                     if([item_data isEqual: [NSNull null]]){
                     item1.imageData = [UIImage imageNamed:@"item_default.png"];
                     newItem.item_picture = [[NSData alloc] init];
                     }
                     else{
                     NSData *pictureData =[[NSData alloc] initWithBase64EncodedString:item_data options:0];
                     //NSLog(@"%@",pictureData);
                     item1.imageData = [UIImage imageWithData:pictureData];
                     newItem.item_picture = pictureData;
                     }
                     //item1.imageData = [UIImage imageNamed:@"item_default.png"];
                     */
                    
                    /*[self.items addObject:item1];
                    NSLog(@"Name: %@, Last-tracked: %@",item1.name, item1.lastTracked);
                    
                    
                    newItem.user_name = user_name;
                    newItem.item_name = [item objectForKey:@"item_name"];
                    newItem.item_description = [item objectForKey:@"item_description"];
                    newItem.item_macAddress = [item objectForKey:@"item_macAddress"];
                    //newItem.item_id = [NSNumber numberWithInt:(int)[[item objectForKey:@"item_id"] integerValue]];
                    newItem.item_isLost = [NSNumber numberWithInt:(int)[[item objectForKey:@"item_isLost"] integerValue]];
                    newItem.item_eLeashRange = [NSNumber numberWithInt:(int)[[item objectForKey:@"item_eLeashRange"] integerValue]];
                    newItem.item_eLeashOn = [NSNumber numberWithInt:(int)[[item objectForKey:@"item_eLeashOn"] integerValue]];
                    newItem.item_DOB = [item objectForKey:@"item_DOB"];
                    newItem.item_lastTracked = [item objectForKey:@"item_lastTracked"];
                    
                    //Now save the context
                    NSError *error = nil;
                    // Save the object to persistent store
                    if (![context save:&error]) {
                        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                    }
                    
                }
            } else {
                if (error) NSLog(@"Error: %@", error);
                [self alertStatus:@"Retriving data failed" :@"Failed to retrieve data"];
            }
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        [self alertStatus:@"Retriving data failed" :@"Failed to retrieve data"];
    }
}
*/

/*
 ** Load from the global database and also add to the local database
 */
- (void) loadFromGlobalDatabase{
        if([user_name isEqualToString:@""]) {
            [self alertStatus:@"Not logged in" :@"Error!"];
        } else {
            NSString *post =[[NSString alloc] initWithFormat:@"user_name=%@",user_name];
            NSLog(@"PostData: %@",post);
            
            NSURL *url=[NSURL URLWithString:@"http://localhost/~kediamanav/login/getUserItems"];
            
            NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            
            NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:url];
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:postData];
            
            
            AFHTTPRequestOperation *datasource_download_operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            
            [datasource_download_operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSData *datasource_data = (NSData *)responseObject;
                
                NSString *responseData = [[NSString alloc]initWithData:datasource_data encoding:NSUTF8StringEncoding];
                NSLog(@"Response ==> %@", responseData);
                
                SBJsonParser *jsonParser = [SBJsonParser new];
                NSArray  *itemList = [jsonParser objectWithString:responseData error:NULL];
                
                NSMutableArray *records = [NSMutableArray array];
                for (NSDictionary *item in itemList){
                    
                    // Now add it to the CoreData database also
                    // Add to persistent store here
                    NSManagedObjectContext *context = [self managedObjectContext];
                    Items *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Items" inManagedObjectContext:context];
                    
                    beaconClass *item1=[[beaconClass alloc] init];
                    item1.name = [item objectForKey:@"item_name"];
                    item1.lastTracked = [item objectForKey:@"item_lastTracked"];
                    
                    NSString *pictureURL = [item objectForKey:@"item_picture"];
                    PhotoRecord *record = [[PhotoRecord alloc] init];
                    if(![pictureURL isEqual: [NSNull null]]){
                        record.URL = [NSURL URLWithString:pictureURL];
                        NSLog(@"pictureURL: %@",pictureURL);
                        record.itemImage = true;
                    }
                    else{
                        record.itemImage = false;
                        newItem.item_picture = [[NSData alloc] init];
                    }
                    
                    [records addObject:record];
                    record = nil;
                    NSLog(@"Size of photos array: %lu", (unsigned long)records.count);
                    item1.imageURL = pictureURL;
                    
                    [self.items addObject:item1];
                    NSLog(@"Name: %@, Last-tracked: %@",item1.name, item1.lastTracked);
                    
                    newItem.user_name = user_name;
                    newItem.item_name = [item objectForKey:@"item_name"];
                    newItem.item_description = [item objectForKey:@"item_description"];
                    newItem.item_macAddress = [item objectForKey:@"item_macAddress"];
                    //newItem.item_id = [NSNumber numberWithInt:(int)[[item objectForKey:@"item_id"] integerValue]];
                    newItem.item_isLost = [NSNumber numberWithInt:(int)[[item objectForKey:@"item_isLost"] integerValue]];
                    newItem.item_eLeashRange = [NSNumber numberWithInt:(int)[[item objectForKey:@"item_eLeashRange"] integerValue]];
                    newItem.item_eLeashOn = [NSNumber numberWithInt:(int)[[item objectForKey:@"item_eLeashOn"] integerValue]];
                    newItem.item_DOB = [item objectForKey:@"item_DOB"];
                    newItem.item_lastTracked = [item objectForKey:@"item_lastTracked"];
                    
                    //Now save the context
                    NSError *error = nil;
                    // Save the object to persistent store
                    if (![context save:&error]) {
                        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                    }
                }
                self.totalItems = self.items.count;
                self.photos = records;
                NSLog(@"Before table reload");
                [self.tableView reloadData];
                NSLog(@"After table reload");
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                alert = nil;
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            }];
            NSLog(@"Before add operation");
            [self.pendingOperations.downloadQueue addOperation:datasource_download_operation];
            NSLog(@"After calling add operation");
        }
}

/*
 **This function loads the table with the data from the server
 */
- (void)loadTableData{
    
    //Load the data into the array, this is from the server
    //First clear the array and then load data into the array
    [self.items removeAllObjects];
    [self.photos removeAllObjects];
     
    //Choose between the 2 based on whether the database exists or not
    if(_loadFromLocal==1){
        [self loadFromLocalDatabase];
    }
    else{
        //Clear the local database
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Items"];
        
        //For conditional fetching
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"user_name=%@",user_name];
        [request setPredicate:filter];
        
        //Add to persistent store here
        NSManagedObjectContext *context = [self managedObjectContext];
        
        NSArray *fetchedObjects = [context executeFetchRequest:request error:nil];
        
        for(Items *item in fetchedObjects){
            //For deleting an object
            [context deleteObject:item];
        }
        
        [self loadFromGlobalDatabase];
    }
}

- (void) alertStatus : (NSString *)msg :(NSString *)title{
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertview show];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.items count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListPrototypeCell" forIndexPath:indexPath];
    BeaconTableViewCell *cell = (BeaconTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ListPrototypeCell" forIndexPath:indexPath];

    /*if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ListPrototypeCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }*/
    // Configure the cell...
    beaconClass *curItem = [self.items objectAtIndex:indexPath.row];
    cell.nameLabel.text = curItem.name;
    cell.lastTrackedLabel.text=curItem.lastTracked;
    
    PhotoRecord *aRecord = [self.photos objectAtIndex:indexPath.row];
    
    if(aRecord.loadFromLocal){
        [cell.activityBar setHidden:true];
        cell.thumbnailImage.image = [UIImage imageWithData:curItem.imageData];
    }
    else if(!(aRecord.itemImage)||aRecord.isFailed){
        [cell.activityBar stopAnimating];
        [cell.activityBar setHidden:true];
        cell.thumbnailImage.image = [UIImage imageNamed:@"item_default.png"];
        //Increase the number of items loaded
        self.itemsLoaded = self.itemsLoaded +1;
    }
    else if (aRecord.hasImage) {
        [cell.activityBar stopAnimating];
        [cell.activityBar setHidden:true];
        cell.thumbnailImage.image = aRecord.image;
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Items"];
    
        // For conditional fetching
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"(user_name=%@) AND (item_name=%@)",user_name,curItem.name];
        [request setPredicate:filter];
        
        //Add to persistent store here
        NSManagedObjectContext *context = [self managedObjectContext];
        
        NSError *error = nil;
        Items *item = nil;
        item = [[context executeFetchRequest:request error:&error] lastObject];
        
        if(error){
            NSLog(@"Can't execute fetch request! %@ %@", error, [error localizedDescription]);
        }
        if(item){
            item.item_picture = aRecord.imageData;
            error = nil;
            if (![context save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
            else{
                //Increase the number of items loaded
                self.itemsLoaded = self.itemsLoaded +1;
            }
        }
        //cell.thumbnailImage.image = [UIImage imageWithData:item.item_picture];
    }
    else {
        [cell.activityBar startAnimating];
        [self startOperationsForPhotoRecord:aRecord atIndexPath:indexPath];
    }
    
    /*UIImage *cellImage;
    if([curItem.imageURL isEqual: [NSNull null]]){
        cellImage = [UIImage imageNamed:@"item_default.png"];
    }
    else{
        NSURL *imageURL = [NSURL URLWithString:curItem.imageURL];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        cellImage = [UIImage imageWithData:imageData];
    }
    cell.thumbnailImage.image = cellImage;*/
     
     
    cell.thumbnailImage.layer.cornerRadius = cell.thumbnailImage.frame.size.width /2;
    cell.thumbnailImage.clipsToBounds = YES;
    
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = [UIView new];
    cell.selectedBackgroundView = [UIView new];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)startOperationsForPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath {

    if (!record.hasImage) {
        [self startImageDownloadingForRecord:record atIndexPath:indexPath];
    }
}

- (void)startImageDownloadingForRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%ld",(long)indexPath.row);
    if (![self.pendingOperations.downloadsInProgress.allKeys containsObject:indexPath]) {
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithPhotoRecord:record atIndexPath:indexPath delegate:self];
        [self.pendingOperations.downloadsInProgress setObject:imageDownloader forKey:indexPath];
        [self.pendingOperations.downloadQueue addOperation:imageDownloader];
    }
}

- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader {
    
    NSIndexPath *indexPath = downloader.indexPathInTableView;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.pendingOperations.downloadsInProgress removeObjectForKey:indexPath];
}


@end
