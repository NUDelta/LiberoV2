//
//  CurrentPickUpTableViewController.m
//  Libero
//
//  Created by Yongsung on 2/28/15.
//  Copyright (c) 2015 YK. All rights reserved.
//

#import "CurrentPickUpTableViewController.h"

#import <Parse/Parse.h>
#import "MyUser.h"
#import "RWDropdownMenu.h"

@interface CurrentPickUpTableViewController ()
@property (nonatomic, strong) NSArray *requests;
@property (nonatomic, strong) NSString *packageType;
@property (nonatomic, strong) NSString *username;

@property (assign) BOOL notNotified;
@property (assign) CLLocationCoordinate2D currentLoc;
@property (strong, nonatomic) NSIndexPath *myIndexPath;
@property (nonatomic, strong) NSMutableArray *myHelpRequests;
@property (nonatomic, assign) RWDropdownMenuStyle menuStyle;

@end

@implementation CurrentPickUpTableViewController

- (void)CurrentPickUpRequests
{
    NSMutableArray *tmpRequest = [[NSMutableArray alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *tmpRequest = [[NSMutableArray alloc] init];
        if(!error) {
            for(PFObject *object in objects){
                if(![(NSString *)object[@"username"] isEqualToString:(NSString *)[MyUser currentUser].username] && [object[@"deliverer"] isEqualToString:[MyUser currentUser].username] && ![object[@"delivered"] isEqualToString:@"waiting for pick up"]) {
                    NSLog(@"found %@",object[@"deliverer"]);
                    [tmpRequest addObject: object];
                }
            }
        }
        self.requests = tmpRequest;
    }];
}

- (void)setRequests:(NSArray *)requests
{
    _requests = requests;
    [self.tableView reloadData];
}

- (void)setUsername:(NSString *)username
{
    [self.tableView reloadData];
}

- (void)presentStyleMenu:(id)sender
{
    NSArray *styleItems =
    @[
      [RWDropdownMenuItem itemWithText:@"Friend's Requests" image:nil action:^{
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
      [RWDropdownMenuItem itemWithText:@"Chat Sessions" image:nil action:^{
          UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"chatNav"];
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
      ];
    
    [RWDropdownMenu presentFromViewController:self withItems:styleItems align:RWDropdownMenuCellAlignmentCenter style:self.menuStyle navBarImage:nil completion:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    //    [self.tableView deselectRowAtIndexPath:self.myIndexPath animated:YES];
    [self CurrentPickUpRequests];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UINavigationItem *nav = self.navigationItem;
    nav.title = @"Current Pick ups";
    
    self.navigationController.navigationBarHidden=NO;
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [titleButton setImage:[[UIImage imageNamed:@"down@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [titleButton setTitle:@"Current Pickups" forState:UIControlStateNormal];
    [titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
    [titleButton addTarget:self action:@selector(presentStyleMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    [titleButton sizeToFit];
    self.navigationItem.titleView = titleButton;
    
    self.requests = [[NSMutableArray alloc]init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)appUsageLogging: (NSString *)activity {
    PFObject *usage = [PFObject objectWithClassName:@"UsageLog"];
    usage[@"username"] = [MyUser currentUser].username;
    usage[@"userid"] = [MyUser currentUser].objectId;
    usage[@"activity"] = activity;
    [usage saveInBackground];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.requests count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"here too");
    NSDictionary *request = self.requests[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Sharer Request Cell" forIndexPath:indexPath];
    cell.textLabel.text = [request valueForKeyPath:@"username"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMMM d, YYYY hh:mm a";
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"CST"];
    NSString *dateWithNewFormat = [dateFormatter stringFromDate:[request valueForKeyPath:@"updatedAt"]];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Status: %@\nupdatedAt: %@", [request valueForKeyPath:@"delivered"], dateWithNewFormat];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Are you gonna pick this up?" message:@"If you click YES, email notification will be sent to the recipient." delegate:self cancelButtonTitle:@"NO" otherButtonTitles: nil];
    //    [alert addButtonWithTitle:@"YES"];
    //    [alert show];
    self.myIndexPath = indexPath;
    NSLog(@"index button clicked");
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    self.myIndexPath = indexPath;
    NSLog(@"index button clicked");
    //    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Are you gonna pick this up?" message:@"If you click YES, email notification will be sent to the recipient." delegate:self cancelButtonTitle:@"NO" otherButtonTitles: nil];
    //    [alert addButtonWithTitle:@"YES"];
    //    [alert show];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
