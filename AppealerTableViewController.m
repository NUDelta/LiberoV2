//
//  AppealerTableViewController.m
//  LocationNotifier
//
//  Created by Yongsung on 10/14/14.
//  Copyright (c) 2014 NU. All rights reserved.
//

#import "AppealerTableViewController.h"
#import "AddRequestViewController.h"
#import "MyUser.h"
#import <Parse/Parse.h>
#import "DelivererViewController.h"
#import "AppDelegate.h"
#import "RWDropdownMenu.h"
#import "ChatWallViewController.h"


@interface AppealerTableViewController () <UIAlertViewDelegate, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) NSMutableArray *requests;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, assign) RWDropdownMenuStyle menuStyle;
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

- (void)presentStyleMenu:(id)sender
{
    NSArray *styleItems =
    @[
      [RWDropdownMenuItem itemWithText:@"Other's Requests" image:nil action:^{
          UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"friendR"];
          myNav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
          [self presentViewController:myNav animated:YES completion:nil];
          self.menuStyle = RWDropdownMenuStyleBlackGradient;
      }],
      [RWDropdownMenuItem itemWithText:@"Current Pickups" image:nil action:^{
          UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"currentPickupNav"];
          myNav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
          [self presentViewController:myNav animated:YES completion:nil];
          self.menuStyle = RWDropdownMenuStyleTranslucent;
      }],
      [RWDropdownMenuItem itemWithText:@"My Requests" image:nil action:^{
          UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"requestsNav"];
          myNav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
          [self presentViewController:myNav animated:YES completion:nil];
          self.menuStyle = RWDropdownMenuStyleTranslucent;
      }],
      [RWDropdownMenuItem itemWithText:@"New Request" image:nil action:^{
          UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"addRequestNav"];
          myNav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
          [self presentViewController:myNav animated:YES completion:nil];
          self.menuStyle = RWDropdownMenuStyleTranslucent;
      }],
      [RWDropdownMenuItem itemWithText:@"Profile" image:nil action:^{
          UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"profileNav"];
          myNav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
          [self presentViewController:myNav animated:YES completion:nil];
          self.menuStyle = RWDropdownMenuStyleTranslucent;
      }],
      ];

    
    [RWDropdownMenu presentFromViewController:self withItems:styleItems align:RWDropdownMenuCellAlignmentCenter style:self.menuStyle navBarImage:nil completion:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden=NO;
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [titleButton setImage:[[UIImage imageNamed:@"down@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [titleButton setTitle:@"My Requests" forState:UIControlStateNormal];
    [titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
    [titleButton addTarget:self action:@selector(presentStyleMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    [titleButton sizeToFit];
    self.navigationItem.titleView = titleButton;
    
    UINavigationItem *navItem = self.navigationItem;
    navItem.title = @"My request";
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem)];
    navItem.rightBarButtonItem = bbi;
    navItem.leftBarButtonItem = self.editButtonItem;
    
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

- (void)addNewItem {
    //    [self performSegueWithIdentifier:@"AddRequestModal" sender:self];
    //    AddRequestViewController *arvc = [[AddRequestViewController alloc]init];
    //    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:arvc];
    //    arvc.modalPresentationStyle = UIModalPresentationCurrentContext;
    //    [self presentViewController:nav animated:YES completion:NULL];
    
    UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"addRequestNav"];
    myNav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:myNav animated:YES completion:nil];
    self.menuStyle = RWDropdownMenuStyleTranslucent;
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
    NSDictionary *request = self.requests[self.requests.count - 1 - indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Appealer Request Cell" forIndexPath:indexPath];
    if([(NSString *)[request valueForKeyPath:@"deliverer"] isEqualToString:@"null"])
        cell.textLabel.text = @"Waiting for pickup";
    else
        cell.textLabel.text = [NSString stringWithFormat:@"Helper name: %@", [request valueForKeyPath:@"deliverer"]];
//    cell.textLabel.text = [NSString stringWithFormat:@"Tracking #: %@", [request valueForKeyPath:@"trackingNumber"]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMMM d, YYYY hh:mm a";
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"CST"];
    NSString *dateWithNewFormat = [dateFormatter stringFromDate:[request valueForKeyPath:@"createdAt"]];
    NSString *desc = [request valueForKeyPath:@"itemDescription"] ? [request valueForKeyPath:@"itemDescription"]: @"no description";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Description: %@\nStatus: %@\nRequested at: %@", desc, [request valueForKeyPath:@"delivered"], dateWithNewFormat];
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

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"deleted");
        PFQuery *query = [PFQuery queryWithClassName:@"Message"];
        [query getObjectInBackgroundWithId:[self.requests[self.requests.count - 1 - indexPath.row] valueForKeyPath:@"objectId"] block:^(PFObject *object, NSError *error) {
            if(!error) {
                object[@"cancelled"] = @"true";
                NSLog(@"requets count: %d", [self.requests count]);
                NSLog(@"%@", indexPath.description);
                [self.requests removeObjectAtIndex: self.requests.count - 1 - indexPath.row];
                NSLog(@"requets count: %d", [self.requests count]);
                [object saveInBackground];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }];
        
    }
}

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
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    NSDictionary *request = self.requests[self.requests.count -1 - indexPath.row];
    
    NSLog(@"======================deliverer %@", [request valueForKeyPath:@"deliverer"]);
    if([(NSString *)[request valueForKeyPath:@"deliverer"] isEqualToString:@"null"]) {
        
        if([segue.identifier isEqualToString:@"chatV2"]) {
            if([segue.destinationViewController isKindOfClass:[ChatWallViewController class]]) {
                ChatWallViewController *cvc = [segue destinationViewController];
                NSLog(@"%@", [request valueForKeyPath:@"deliverer"]);
                cvc.other = @"notdelivered";
                cvc.detailChat = NO;
                //cvc.objId = [request valueForKey:@"objectId"];
                NSLog(@"segueing");
            }
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Waiting for pickup"
                                                message: @"We're sorry, your package hasn't been picked up yet!"
                                                delegate: self
                                                cancelButtonTitle: @"OK"
                                                otherButtonTitles: nil,nil];
        [alert show];

        
    } else if([sender isKindOfClass:[UITableViewCell class]]) {
            
            if([segue.identifier isEqualToString:@"chatV2"]) {
                if([segue.destinationViewController isKindOfClass:[ChatWallViewController class]]) {
                    ChatWallViewController *cvc = [segue destinationViewController];
                    NSLog(@"%@", [request valueForKeyPath:@"deliverer"]);
                    cvc.other = [NSString stringWithFormat:@"%@", [request valueForKeyPath:@"deliverer"]];
                    cvc.detailChat = NO;
                    //cvc.objId = [request valueForKey:@"objectId"];
                    NSLog(@"segueing");
                }
            }
    }
    
    
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
/*- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if([segue.identifier isEqualToString:@"Show Deliverer Info"]) {
            if([segue.destinationViewController isKindOfClass:[DelivererViewController class]]) {
                DelivererViewController *dvc = [segue destinationViewController];
                dvc.request = self.requests[self.requests.count - 1 - indexPath.row];
                NSLog(@"segueing");
            }
        }
    }
}*/

@end
