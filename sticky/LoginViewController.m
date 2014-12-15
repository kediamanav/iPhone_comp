//
//  LoginViewController.m
//  sticky
//
//  Created by Manav Kedia on 10/10/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "Users.h"
#import "SBJson.h"

@interface LoginViewController ()
- (IBAction)loginPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *tfEmail;
@property (weak, nonatomic) IBOutlet UITextField *tfPassword;
@property (weak, nonatomic) IBOutlet UIButton *b_login;
@property (weak, nonatomic) IBOutlet UIButton *b_register;
@property (weak, nonatomic) NSString *l_username;
@property (weak, nonatomic) NSString *l_email;
@property (weak, nonatomic) NSString *l_password;
@property NSInteger *loadFromLocal;

- (IBAction)registerPressed:(id)sender;

@end

@implementation LoginViewController

-(IBAction)unwindToLogin:(UIStoryboardSegue *)segue{
    
}

#pragma mark - Coredata
/* To recover the managed context object from the app delegate*/
- (NSManagedObjectContext *)managedObjectContext{
    NSManagedObjectContext *context = nil;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = delegate.coreDataHelper.managedObjectContext;
    return context;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"loggedInSegue"]){
        NSLog(@"Prepare for segue: %@", segue.identifier);
        UINavigationController *segueNavigation = [segue destinationViewController];
        mainTableViewController *transferViewController = (mainTableViewController *)[[segueNavigation viewControllers] objectAtIndex:0];
        NSLog(@"HERE: %@", [_tfEmail text]);
        transferViewController.user_name = [[NSString alloc] initWithFormat:@"%@", _l_username];
        transferViewController.loadFromLocal = _loadFromLocal;
    }
}


-(void) checkIfUserLoggedIn{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Users"];
    
    /* For conditional fetching*/
    //NSPredicate *filter = [NSPredicate predicateWithFormat:@"user_name = 'kediamanav'"];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"user_loggedin == %d",[[NSNumber numberWithInt:1] intValue]];
    [request setPredicate:filter];
    
    //Add to persistent store here
    NSManagedObjectContext *context = [self managedObjectContext];
    if(context==nil){
        NSLog(@"Context is nil");
    }
    
    NSArray *fetchedObjects = [context executeFetchRequest:request error:nil];
    
    for(Users *user in fetchedObjects){
        NSLog(@"password:%@, email:%@, username:%@",user.user_password,user.user_email,user.user_name);
        _l_username = user.user_name;
        _l_email = user.user_email;
        _loadFromLocal = 1;
        [self performSegueWithIdentifier:@"loggedInSegue" sender:self];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkIfUserLoggedIn];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) alertStatus : (NSString *)msg :(NSString *)title{
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertview show];
}




#pragma mark - Add user to local database
// Function to add new user to local database
- (void)addUser{
    
        //Add to persistent store here
        NSManagedObjectContext *context = [self managedObjectContext];
        
        // Create a new managed object
        Users *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"Users" inManagedObjectContext:context];
        newUser.user_email = _l_email;
        newUser.user_name = _l_username;
        newUser.user_password = _l_password;
        newUser.user_loggedin = [NSNumber numberWithInt:(int)1];
    
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save User to local database! %@ %@", error, [error localizedDescription]);
        }
        else{
            NSLog(@"User successfully added to local database");
        }
}

#pragma mark - Login global and local
//Function that does the global login and also stores the user credentials in the local database
- (void) globalLogin{
    @try {
        
        if([[_tfEmail text] isEqualToString:@""] || [[_tfPassword text] isEqualToString:@""] ) {
            [self alertStatus:@"Please enter both Username and Password" :@"Login Failed!"];
        } else {
            NSString *post =[[NSString alloc] initWithFormat:@"user_name=%@&user_password=%@&user_rememberme=%@",[_tfEmail text],[_tfPassword text],@"true"];
            NSLog(@"PostData: %@",post);
            
            NSURL *url=[NSURL URLWithString:@"http://localhost/~kediamanav/login/login"];
            
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
                NSLog(@"Response ==> %@", responseData);
                
                SBJsonParser *jsonParser = [SBJsonParser new];
                NSArray  *jsonData = [jsonParser objectWithString:responseData error:NULL];
                
                //NSDictionary *jsonData = (NSDictionary *) [jsonParser objectWithString:responseData error:nil];
                //NSInteger success = [(NSNumber *) [jsonData objectForKey:@"success"] integerValue];
                NSLog(@"%@",jsonData);
                
                NSInteger success;
                for (NSDictionary *user in jsonData){
                    success = [(NSNumber *)[user objectForKey:@"success"] integerValue];
                }
                
                NSLog(@"%ld",(long)success);
                if(success == 1)
                {
                    for (NSDictionary *user in jsonData){
                        _l_username = (NSString *) [user objectForKey:@"user_name"];
                        _l_email = (NSString *) [user objectForKey:@"user_email"];
                        _l_password = _tfPassword.text;
                        NSLog(@"username:%@, email:%@, password:%@",_l_username,_l_email,_l_password);
                        [self addUser];
                    }
                    [self performSegueWithIdentifier:@"loggedInSegue" sender:self];
                    //Connect to the next seque here
                    //NSLog(@"Login SUCCESS");
                    //[self alertStatus:@"Logged in Successfully." :@"Login Success!"];
                    
                } else {
                    NSString *error_msg;
                    for (NSDictionary *user in jsonData){
                        error_msg = (NSString *) [user objectForKey:@"error_message"];
                    }
                    [self alertStatus:error_msg :@"Login Failed!"];
                }
                
            } else {
                if (error) NSLog(@"Error: %@", error);
                [self alertStatus:@"Connection Failed" :@"Login Failed!"];
            }
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        [self alertStatus:@"Login Failed." :@"Login Failed!"];
    }
}

- (void)checkLocalLogin{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Users"];
    
    /* For conditional fetching*/
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"(user_name=%@) OR (user_email=%@)",_tfEmail.text,_tfEmail.text];
    [request setPredicate:filter];
    
    //Add to persistent store here
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSArray *fetchedObjects = [context executeFetchRequest:request error:nil];
    
    for(Users *user in fetchedObjects){
        NSLog(@"Fetched Object = %@",user.user_name);
        NSLog(@"local password:%@, typed password:%@",user.user_password,_tfPassword.text);
        if([user.user_password isEqual:_tfPassword.text]){
            _l_username = user.user_name;
            _l_email = user.user_email;
            _loadFromLocal = 1;
            [self performSegueWithIdentifier:@"loggedInSegue" sender:self];
        }
    }
}


- (IBAction)loginPressed:(id)sender {
    _loadFromLocal = 0;

    [self checkLocalLogin];
    if(_loadFromLocal==0){
        [self globalLogin];
    }
}


- (IBAction)registerPressed:(id)sender {
}
@end
