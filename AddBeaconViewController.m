//
//  AddBeaconViewController.m
//  sticky
//
//  Created by Manav Kedia on 15/10/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import "AddBeaconViewController.h"

@interface AddBeaconViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *pictureBeacon;
@property (weak, nonatomic) IBOutlet UITextField *nameBeacon;
@property (weak, nonatomic) IBOutlet UITextView *descriptionBeacon;
- (IBAction)choosePicButton:(id)sender;

@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) NSMutableArray *capturedImages;
@property (nonatomic) NSInteger picTaken;

@end

@implementation AddBeaconViewController

# pragma mark - on load functions
- (void)viewDidLoad {
    self.capturedImages = [[NSMutableArray alloc] init];
    
    self.pictureBeacon.image = [UIImage imageNamed:@"item_default.png"];
    self.pictureBeacon.layer.cornerRadius = self.pictureBeacon.frame.size.width /2;
    self.pictureBeacon.clipsToBounds = YES;
    
    self.tfRange.text = @"0" ;
    self.picTaken = 0;
    
    if([_user_name isEqualToString:@""]){
        [self alertStatus:@"Not logged in" :@"Adding beacon failed!"];
        [self performSegueWithIdentifier:@"unwindSegueToScanBeacon" sender:self];
    }
    else if([_macAddress isEqualToString:@""]){
        [self alertStatus:@"Beacon not identified properly" :@"Adding beacon failed!"];
        [self performSegueWithIdentifier:@"unwindSegueToScanBeacon" sender:self];
    }
}

- (NSManagedObjectContext *)managedObjectContext{
    NSManagedObjectContext *context = nil;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = delegate.coreDataHelper.managedObjectContext;
    return context;
}

#pragma mark - Choose image from camera or from library

//Right now only library function is integrated because we can't test camera with the simulator
/*Function to pick images for the gallery*/
- (IBAction)choosePicButton:(id)sender {
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if (self.capturedImages.count > 0)
    {
        [self.capturedImages removeAllObjects];
    }
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    [self.capturedImages addObject:image];
    [self finishAndUpdate];
}

 - (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)finishAndUpdate
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    if ([self.capturedImages count] > 0)
    {
        if ([self.capturedImages count] == 1)
        {
            // Camera took a single picture.
            [self.pictureBeacon setImage:[self.capturedImages objectAtIndex:0]];
        }
        else
        {
            [self.pictureBeacon setImage:[self.capturedImages objectAtIndex:self.capturedImages.count-1]];
        }
        
        // To be ready to start again, clear the captured images array.
        self.picTaken = 1;
        [self.capturedImages removeAllObjects];
    }
    
    self.imagePickerController = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Sending the new data to server

/* Create alert if some required field something is missing*/
- (void) alertStatus : (NSString *)msg :(NSString *)title{
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertview show];
}

# pragma mark - Save to database

/* Saves to local database*/
- (void) saveToLocalDatabase : (NSString *)item_name :(NSString *) item_description :(NSInteger ) range :(NSInteger ) isLost :(NSInteger ) eLeashOn :(NSString *)dateTimeStamp{
    //Add to persistent store here
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // Create a new managed object
    Items *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Items" inManagedObjectContext:context];
    newItem.user_name = _user_name;
    newItem.item_name = item_name;
    newItem.item_description = item_description;
    newItem.item_macAddress = _macAddress;
    newItem.item_isLost = [NSNumber numberWithInt:(int)isLost];
    newItem.item_eLeashRange = [NSNumber numberWithInt:(int)range];
    newItem.item_eLeashOn = [NSNumber numberWithInt:(int)eLeashOn];
    newItem.item_DOB = dateTimeStamp;
    newItem.item_lastTracked = dateTimeStamp;
    newItem.item_modified = [NSNumber numberWithInt:(int)1];
    
    if(self.picTaken == 1){
        NSData *imageData = UIImageJPEGRepresentation(self.pictureBeacon.image, 90);
        newItem.item_picture = imageData;
    }
    else{
        newItem.item_picture = nil;
    }
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        [self alertStatus:[error localizedDescription]:@"Adding beacon Failed!"];
        [self performSegueWithIdentifier:@"unwindSegueToScanBeacon" sender:self];
    }
    else{
        [self alertStatus:@"Adding beacon successful!" : @"Successful"];
        [self performSegueWithIdentifier:@"unwindAfterAddingBeacon" sender:self];
        //Call the save to global database
        //[self saveToGlobalDatabase:newItem];
    }
}

/* Saves to global database
- (void) saveToGlobalDatabase : (Items *)item{
    
    //Creating the key-value pair arrays to hold the post data
    NSArray *keys = [[NSArray alloc] initWithObjects:@"user_name",@"item_name",@"item_DOB",@"item_lastTracked",@"item_description",@"item_eLeashRange",@"item_isLost",@"item_eLeashOn",@"item_macAddress", nil];
    NSArray *vals = [[NSArray alloc] initWithObjects:item.user_name,item.item_name, item.item_DOB, item.item_lastTracked, item.item_description, item.item_eLeashRange, item.item_isLost, item.item_eLeashOn , item.item_macAddress, nil];

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
    if(item.item_picture != nil){
        //Imagedata file
        NSLog(@"The item had an image");
        NSData *imageData = item.item_picture;
        
        NSString *imageName= item.user_name;
        imageName = [imageName stringByAppendingString:@"_"];
        imageName = [imageName stringByAppendingString:item.item_name];
        
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

    AFHTTPRequestOperation *datasource_upload_operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSLog(@"Just before executing afnetworking");
    //NSError *error = [[NSError alloc] init];
    //NSHTTPURLResponse *response = nil;
    //NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    [datasource_upload_operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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
    [self.pendingOperations.uploadQueue addOperation:datasource_upload_operation];
    NSLog(@"After calling addItem operation");
}
*/

/* Sends the data of the newly added item to the server*/
- (void) sendDataToServer : (NSString *)item_name :(NSString *) item_description :(NSInteger ) range :(NSInteger ) isLost :(NSInteger ) eLeashOn {
    
    //Getting today's date
    NSDate *currentTime = [[NSDate alloc] init];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateTimeStamp = [dateFormat stringFromDate:currentTime];
    NSLog(@"%@",dateTimeStamp);
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    if([item_name isEqualToString:@""]) {
        [self alertStatus:@"Please enter the name of the item" :@"Adding beacon failed!"];
    }
    else{
        [self saveToLocalDatabase:item_name :item_description :range :isLost :eLeashOn :dateTimeStamp];
    }
}

#pragma mark - UI button functionalities

- (IBAction)counterPressed:(id)sender {
    self.tfRange.text = [NSString stringWithFormat:@"%.f", self.rangeCounter.value];
}

- (IBAction)addButtonPressed:(id)sender {
    NSString *item_name = _nameBeacon.text;
    NSString *item_description = _descriptionBeacon.text;
    NSInteger range = _tfRange.text.integerValue;
    NSInteger eLeashOn;
    if(range==0){
        eLeashOn=0;
    }
    else{
        eLeashOn=1;
    }
    NSInteger isLost=0;
    NSLog(@"%@, %@, %@, %@, %ld, %ld, %ld", _user_name, _macAddress, item_name, item_description, (long)range, (long)eLeashOn, (long)isLost);
    
    //Sends the data to the server, replace with the local database
    [self sendDataToServer: item_name : item_description : range : isLost : eLeashOn];
}


@end
