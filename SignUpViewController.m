//
//  SignUpViewController.m
//  sticky
//
//  Created by Manav Kedia on 10/10/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *user_email;
@property (weak, nonatomic) IBOutlet UITextField *user_password;
@property (weak, nonatomic) IBOutlet UITextField *user_password_repeat;
@property (weak, nonatomic) IBOutlet UIButton *b_register;
- (IBAction)registerClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *user_username;
@property (weak,nonatomic) NSString *l_username;
@property (weak,nonatomic) NSString *l_email;
@property (weak,nonatomic) NSString *l_password;


@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"registeredSegue"]){
        NSLog(@"Prepare for segue: %@", segue.identifier);
        UINavigationController *segueNavigation = [segue destinationViewController];
        mainTableViewController *transferViewController = (mainTableViewController *)[[segueNavigation viewControllers] objectAtIndex:0];
        NSLog(@"HERE: %@", [_user_username text]);
        transferViewController.user_name = [[NSString alloc] initWithFormat:@"%@", [_user_username text]];
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void) alertStatus : (NSString *)msg :(NSString *)title{
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertview show];
}


#pragma mark - Coredata
/* To recover the managed context object from the app delegate*/
- (NSManagedObjectContext *)managedObjectContext{
    NSManagedObjectContext *context = nil;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = delegate.coreDataHelper.managedObjectContext;
    return context;
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



-(void) registerGlobally{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    @try {
        if([[_user_username text] isEqualToString:@""] || [[_user_email text] isEqualToString:@""] || [[_user_password text] isEqualToString:@""] || [[_user_password_repeat text] isEqualToString:@""]) {
            [self alertStatus:@"Please enter all the fields" :@"Registration Failed!"];
        } else {
            NSString *post =[[NSString alloc] initWithFormat:@"user_name=%@&user_email=%@&user_password_new=%@&user_password_repeat=%@",[_user_username text],[_user_email text],[_user_password text],[_user_password_repeat text]];
            NSLog(@"PostData: %@",post);
            
            NSURL *url=[NSURL URLWithString:@"http://localhost/~kediamanav/login/register_action"];
            
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
                NSDictionary *jsonData = (NSDictionary *) [jsonParser objectWithString:responseData error:nil];
                NSLog(@"%@",jsonData);
                NSInteger success = [(NSNumber *) [jsonData objectForKey:@"success"] integerValue];
                NSLog(@"%ld",(long)success);
                if(success == 1)
                {
                    _l_username = _user_username.text;
                    _l_password = _user_password.text;
                    _l_email = _user_email.text;
                    
                    NSLog(@"username: %@, email: %@, password:%@",_l_username,_l_email,_l_password);
                    [self addUser];
                    [self performSegueWithIdentifier:@"registeredSegue" sender:self];
                    //NSLog(@"Login SUCCESS");
                    //Connect to the next seque here
                    //[self alertStatus:@"Logged in Successfully." :@"Login Success!"];
                    
                } else {
                    
                    NSString *error_msg = (NSString *) [jsonData objectForKey:@"error_message"];
                    [self alertStatus:error_msg :@"Registration Failed!"];
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                }
                
            } else {
                if (error) NSLog(@"Error: %@", error);
                [self alertStatus:@"Connection Failed" :@"Registration Failed!"];
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            }
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        [self alertStatus:@"Registration Failed." :@"Registration Failed!"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }

}


- (IBAction)registerClicked:(id)sender {
    [self registerGlobally];
}

@end
