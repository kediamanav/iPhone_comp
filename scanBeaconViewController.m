//
//  scanBeaconViewController.m
//  sticky
//
//  Created by Manav Kedia on 08/10/14.
//  Copyright (c) 2014 Manav Kedia. All rights reserved.
//

#import "scanBeaconViewController.h"

@interface scanBeaconViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *scanner;
@property (weak, nonatomic) IBOutlet UITableView *beaconTable;
@property (weak, nonatomic) IBOutlet UILabel *headerText;

@end

@implementation scanBeaconViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.beaconTable setHidden:YES];
    
    self.beaconTable.backgroundColor = [UIColor clearColor];
    self.beaconTable.backgroundView = [UIView new];
    
    //Call for loading the beacons here and as soon as we get the data display the table view and hide the activity indicator
    //sampleFunctionCall();
    //Just putting a simple wait to check the visibilities
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.scanner stopAnimating];
        [self.beaconTable setHidden:NO];
        [self.headerText setText:(@"Devices found!")];
        [self.headerText setTextAlignment:NSTextAlignmentCenter];
    });
    
    
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
    if([[segue identifier] isEqualToString:@"newBeaconSelected"]){
        NSLog(@"Prepare for segue: %@", segue.identifier);
        NSIndexPath *selectedRowIndex = [self.beaconTable indexPathForSelectedRow];
        UINavigationController *segueNavigation = [segue destinationViewController];
        AddBeaconViewController *transferViewController = (AddBeaconViewController *)[[segueNavigation viewControllers] objectAtIndex:0];
        transferViewController.user_name = self.user_name;
        transferViewController.macAddress = [self.beaconTable cellForRowAtIndexPath:selectedRowIndex].textLabel.text;
        NSLog(@"%@, %@",transferViewController.macAddress, transferViewController.user_name);
    }
}


#pragma mark - Table view data source
//@synthesize beaconTable;


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    //Later we have to set this to the count of the number of beacons detected
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.beaconTable dequeueReusableCellWithIdentifier:@"BeaconCell" forIndexPath:indexPath];
    
    // Configure the cell...
    //We have to configure the cell with the beacon properties
    cell.textLabel.text = @"99:88:77:66:55:44";
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = [UIView new];
    cell.selectedBackgroundView = [UIView new];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"newBeaconSelected" sender:self];
}



- (IBAction) unwindToScanBeacon:(UIStoryboardSegue *)segue{
    
}

@end
