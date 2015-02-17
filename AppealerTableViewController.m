//
//  AppealerTableViewController.m
//  LocationNotifier
//
//  Created by Yongsung on 10/14/14.
//  Copyright (c) 2014 NU. All rights reserved.
//

#import "AppealerTableViewController.h"
#import "MyUser.h"
#import <Parse/Parse.h>
#import "DelivererViewController.h"
#import "AppDelegate.h"

@interface AppealerTableViewController () <UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) NSArray *requests;
@property (nonatomic, strong) NSString *phoneNumber;

@end

@implementation AppealerTableViewController
- (IBAction)logOutButton:(UIBarButtonItem *)sender {
    [PFUser logOut];
    AppDelegate *appDelegateTemp = [[UIApplication sharedApplication]delegate];
    
    UIViewController* rootController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    
    UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:rootController];
    appDelegateTemp.window.rootViewController = navigation;
}

- (void)setRequests:(NSArray *)requests
{
    _requests = requests;
    [self.spinner stopAnimating];
    [self.tableView reloadData];
}

- (void)startDownloadMyRequest
{
    [self.spinner startAnimating];
    NSMutableArray *tmpRequest = [[NSMutableArray alloc]init];
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            for (PFObject *object in objects) {
                NSLog((NSString *)object[@"username"]);
                if([(NSString *)object[@"username"] isEqualToString:(NSString *)[MyUser currentUser].username] && ![(NSString *)object[@"cancelled"] isEqualToString:@"true"]){
                    [tmpRequest addObject: object];
                    NSLog(@"object added");
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.requests = tmpRequest;
            });
        }
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog([PFUser currentUser].username);
    [self startDownloadMyRequest];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"did appear");
    [self appUsageLogging:@"myrequest"];
    [self startDownloadMyRequest];
    [self.tableView reloadData];
    NSLog(@"table View reloaded");
}

- (void)appUsageLogging: (NSString *)activity {
    PFObject *usage = [PFObject objectWithClassName:@"UsageLog"];
    usage[@"username"] = [MyUser currentUser].username;
    usage[@"userid"] = [MyUser currentUser].objectId;
    usage[@"activity"] = activity;
    [usage saveInBackground];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.requests count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *request = self.requests[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Appealer Request Cell" forIndexPath:indexPath];
    if([(NSString *)[request valueForKeyPath:@"deliverer"] isEqualToString:@"null"])
        cell.textLabel.text = @"No Helper";
    else
        cell.textLabel.text = [NSString stringWithFormat:@"Helper name: %@", [request valueForKeyPath:@"deliverer"]];
//    cell.textLabel.text = [NSString stringWithFormat:@"Tracking #: %@", [request valueForKeyPath:@"trackingNumber"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Delivery status: %@\nTracking #: %@", [request valueForKeyPath:@"delivered"], [request valueForKeyPath:@"trackingNumber"]];
    return cell;
}

//- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
//{
//    NSDictionary *request = self.requests[indexPath.row];
//    PFQuery *query = [MyUser query];
//    [query whereKey:@"objectId" equalTo: [request valueForKeyPath:@"delivererId"]];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        NSLog(((MyUser *)objects[0]).additional);
//        self.phoneNumber = ((MyUser *)objects[0]).additional;
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [NSString stringWithFormat:@"telprompt://%@", self.phoneNumber]]];
//    }];
    
//    self.phoneNumber = [request valueForKeyPath:@"deliverernum"];
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Wanna call deliverer?" message:@"Click YES to call the deliverer." delegate:self cancelButtonTitle:@"NO" otherButtonTitles: nil];
//    [alert addButtonWithTitle:@"YES"];
//    [alert show];
//}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//    NSDictionary *request = self.requests[indexPath.row];
//    PFQuery *query = [MyUser query];
//    [query whereKey:@"objectId" equalTo: [request valueForKeyPath:@"delivererId"]];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        NSLog(((MyUser *)objects[0]).additional);
//        self.phoneNumber = ((MyUser *)objects[0]).additional;
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [NSString stringWithFormat:@"telprompt://%@", self.phoneNumber]]];
//
//    }];
    
//    self.phoneNumber = [request valueForKeyPath:@"deliverernum"];
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Wanna call deliverer?" message:@"Click YES to call the deliverer." delegate:self cancelButtonTitle:@"NO" otherButtonTitles: nil];
//    [alert addButtonWithTitle:@"YES"];
//    [alert show];
//}

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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if([segue.identifier isEqualToString:@"Show Deliverer Info"]) {
            if([segue.destinationViewController isKindOfClass:[DelivererViewController class]]) {
                DelivererViewController *dvc = [segue destinationViewController];
                dvc.request = self.requests[indexPath.row];
                NSLog(@"segueing");
            }
        }
    }
}

@end
