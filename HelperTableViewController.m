//
//  HelperTableViewController.m
//  LocationNotifier
//
//  Created by Yongsung on 10/14/14.
//  Copyright (c) 2014 NU. All rights reserved.
//

#import "HelperTableViewController.h"
#import "PackageViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "MyUser.h"
#import "ImageViewController.h"
#import "RWDropdownMenu.h"

@interface HelperTableViewController () <CLLocationManagerDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) NSArray *requests;
@property (nonatomic, strong) NSString *packageType;
@property (nonatomic, strong) NSString *username;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLCircularRegion *region;
@property (assign) BOOL notNotified;
@property (assign) CLLocationCoordinate2D currentLoc;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) NSIndexPath *myIndexPath;
@property (nonatomic, strong) NSMutableArray *myHelpRequests;


@property (nonatomic, assign) RWDropdownMenuStyle menuStyle;


@end

@implementation HelperTableViewController


- (IBAction)indexChanged:(id)sender {
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
            [self HelperRequests];
            [self.tableView reloadData];
            break;
        case 1:
            [self MyHelpRequests];
            [self appUsageLogging:@"myhelp"];
            break;
        default:
            break;
    }
}

- (void)MyHelpRequests
{
    NSMutableArray *tmpRequest = [[NSMutableArray alloc] init];
    for (NSArray *request in self.requests) {
        NSLog(@"help requests - %@", [request valueForKeyPath:@"username"]);
        if([[request valueForKeyPath:@"deliverer"] isEqualToString:[MyUser currentUser].username])
            [tmpRequest addObject:request];
    }
    self.requests = tmpRequest;
}

//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
//{
//    CLLocation *currentLocation = [locations objectAtIndex:0];
//    self.currentLoc = currentLocation.coordinate;
////    [self.locationManager requestStateForRegion:self.region];
////    NSLog(@"My current location is: %f, %f", self.currentLoc.latitude, self.currentLoc.longitude);
////    if(!self.notNotified){
////        [self logCoordinate:@"Delta Lab"];
////        self.notNotified = YES;
////    }
//}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    switch (state) {
        case CLRegionStateInside:
        {
//            NSLog(@"In the Region state");
            
            //        NSDictionary *infoDict = [NSDictionary dictionaryWithObject: @"Package number" forKey: @"Package Key"];
            //        localNotif.userInfo = infoDict;
            //            NSTimer *timer = [[NSTimer alloc]initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:5] interval:0 target:self selector:@selector(testNotification) userInfo:nil repeats:NO];
            if(!self.notNotified) {
                //                [self testNotification];
//                self.notNotified = YES;
            }
            
//            NSLog([NSString stringWithFormat:@"you are at %f, %f", self.currentLoc.latitude, self.currentLoc.longitude]);
            //            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Inside Delta Lab" message:@"Inside" delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
            //            [alert show];
            break;
        }
        case CLRegionStateUnknown:
        case CLRegionStateOutside:
        {
            
            NSLog(@"Not in the Region state");
            break;
        }
        default:
        {
            NSLog(@"default");
        }
            
    }
}


- (void)testNotification
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    // request object Id
//    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:objId forKey:objId];
//    localNotif.userInfo = dictionary;

    if (localNotif) {
        localNotif.alertBody = @"Help your friend to delivery package!";
        localNotif.alertAction = @"Testing notification based on regions";
        localNotif.applicationIconBadgeNumber = 1;
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
    }
}


- (IBAction)logOutButton:(UIBarButtonItem *)sender {
    [PFUser logOut];
    AppDelegate *appDelegateTemp = [[UIApplication sharedApplication]delegate];
    
    UIViewController* rootController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SignInViewController"];
    
    UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:rootController];
    appDelegateTemp.window.rootViewController = navigation;
}

- (void)setRequests:(NSArray *)requests
{
    _requests = requests;
    [self.spinner stopAnimating];
    [self.tableView reloadData];
}

- (void)setUsername:(NSString *)username
{
    [self.tableView reloadData];
}

- (void)HelperRequests
{
    NSLog(@"Index : %d", [self.navigationController.viewControllers indexOfObject:self]);
    [self.spinner startAnimating];
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *tmpRequest = [[NSMutableArray alloc] init];
        
        if(!error) {
            for(PFObject *object in objects){
//FIXME: commented [(NSString *)object[@"residenceHall"] isEqualToString:(NSString *)[MyUser currentUser].residenceHall] or testing purpose
                if(![(NSString *)object[@"username"] isEqualToString:(NSString *)[MyUser currentUser].username] && ![object[@"delivered"] isEqualToString:@"delivered"] && ![(NSString *)object[@"cancelled"] isEqualToString:@"cancelled"]) {
                        NSLog(@"%@", object[@"residenceHall"]);
                        NSLog(@"another one %@", [MyUser currentUser].residenceHall);
                        [tmpRequest addObject: object];
                    }
                }
            }
            self.requests = tmpRequest;
//            dispatch_async(dispatch_get_main_queue(), ^{
//            });
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:self.myIndexPath animated:YES];
    [self HelperRequests];
    [self.tableView reloadData];
}

- (void)presentStyleMenu:(id)sender
{
    NSArray *styleItems =
    @[
      [RWDropdownMenuItem itemWithText:@"Black Gradient" image:nil action:^{
          self.menuStyle = RWDropdownMenuStyleBlackGradient;
      }],
      [RWDropdownMenuItem itemWithText:@"Translucent" image:nil action:^{
          self.menuStyle = RWDropdownMenuStyleTranslucent;
      }],
      ];
    
    [RWDropdownMenu presentFromViewController:self withItems:styleItems align:RWDropdownMenuCellAlignmentCenter style:self.menuStyle navBarImage:nil completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=NO;
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [titleButton setImage:[[UIImage imageNamed:@"nav_down"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [titleButton setTitle:@"Menu Style" forState:UIControlStateNormal];
    [titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
    [titleButton addTarget:self action:@selector(presentStyleMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    [titleButton sizeToFit];
    self.navigationItem.titleView = titleButton;
    

    [self HelperRequests];
//    dispatch_queue_t queue = dispatch_get_main_queue();
    self.myIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate =self;
    
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
        [self.locationManager requestAlwaysAuthorization];
    }
    if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [self.locationManager requestWhenInUseAuthorization];
    }
//    [self.locationManager requestAlwaysAuthorization];
//    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager startUpdatingLocation];
    
    CLLocationCoordinate2D center; //Ford
    center.latitude = 42.056929;
    center.longitude = -87.676519;
    
    CLLocationCoordinate2D plexLeft; //Kellogg
    plexLeft.latitude = 42.053040;
    plexLeft.longitude =  -87.679570;
    
    CLLocationCoordinate2D plexCenter; //Foster Walker
    plexCenter.latitude = 42.053666;
    plexCenter.longitude = -87.677672;
    
    CLCircularRegion *region2 = [[CLCircularRegion alloc] initWithCenter:plexLeft radius:50 identifier:@"Plex Left"];
    CLCircularRegion *region3 = [[CLCircularRegion alloc] initWithCenter:plexCenter radius:50 identifier:@"Plex"];
    
//    [self.locationManager startMonitoringForRegion:self.region];
    [self.locationManager startMonitoringForRegion:region2];
    [self.locationManager startMonitoringForRegion:region3];


//    [self.locationManager requestStateForRegion:self.region];
    [self.locationManager requestStateForRegion:region2];
    [self.locationManager requestStateForRegion:region3];
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter addObserver:self selector:@selector(appDidEnterForeground) name:@"appDidEnterForeground" object:nil];
    [self appUsageLogging:@"appopen"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)appDidEnterForeground {
    NSLog(@"test");
    [self HelperRequests];
    [self.tableView reloadData];
    [self appUsageLogging:@"appopen"];
}

- (void)appUsageLogging: (NSString *)activity {
    PFObject *usage = [PFObject objectWithClassName:@"UsageLog"];
    usage[@"username"] = [MyUser currentUser].username;
    usage[@"userid"] = [MyUser currentUser].objectId;
    usage[@"activity"] = activity;
    [usage saveInBackground];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *request = self.requests[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Sharer Request Cell" forIndexPath:indexPath];
    cell.textLabel.text = [request valueForKeyPath:@"username"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Residence Hall : %@\nEmail: %@\nStatus: %@", [request valueForKeyPath:@"residenceHall"], [request valueForKeyPath:@"email"], [request valueForKeyPath:@"delivered"]];
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

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if(buttonIndex!= alertView.cancelButtonIndex){
//        [self performSegueWithIdentifier:@"Image View Segue" sender:self];
//        NSLog(@"clicked okay");
//        if (self.myIndexPath!=nil) {
//            NSLog(@"calling method pickupemail");
//            [self pickUpEmail:self.myIndexPath];
//        }
//    } else {
//        self.myIndexPath = nil;
//    }
//}

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
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    if([sender isKindOfClass:[UITableViewCell class]]) {
//        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
//        if (indexPath) {
//            if([segue.identifier isEqualToString:@"Show Package Info"]) {
//                if([segue.destinationViewController isKindOfClass:[PackageViewController class]]) {
//                    PackageViewController *pvc = [segue destinationViewController];
//                    pvc.request = self.requests[indexPath.row];
//                }
//            }
//        }
//    }
//}


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self logCoordinate:region.identifier];
    NSLog(@"Welcome to %@", region.identifier);
//    NSLog([self.requests[0] valueForKeyPath:@"username"]);
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if ([self.requests count]>0){
        if (localNotif) {
            NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[self.requests[0] valueForKeyPath:@"objectId"] forKey:[self.requests[0] valueForKeyPath:@"objectId"]];
            localNotif.userInfo = dictionary;
            NSLog(@"%@", [self.requests[0] valueForKeyPath:@"packageType"]);
            if ([self.requests[0] valueForKeyPath:@"packageType"] == NULL)
                localNotif.alertBody = [NSString stringWithFormat:@"Hi %@! Can you pick up a package for me? --%@", [MyUser currentUser].username, [self.requests[0] valueForKeyPath:@"username"]];
            else
                localNotif.alertBody = [NSString stringWithFormat:@"Hi %@! Can you pick up a package (%@ lbs) for me? --%@", [MyUser currentUser].username, [self.requests[0] valueForKeyPath:@"packageType"], [self.requests[0] valueForKeyPath:@"username"]];
            localNotif.alertAction = @"Testing notification based on regions";
            localNotif.soundName = UILocalNotificationDefaultSoundName;
            localNotif.applicationIconBadgeNumber = 1;
            
            PFQuery *query = [MyUser query];
            [query getObjectInBackgroundWithId:[MyUser currentUser].objectId block:^(PFObject *object, NSError *error) {
                if (!error) {
                    int notifCount = [object[@"notifNum"] intValue];
                    NSLog(@"%d", notifCount);
                    NSNumber *value = [NSNumber numberWithInt:notifCount+1];
                    object[@"notifNum"] = value;
                    [object saveInBackground];
                } else {
                    NSLog(@"ERROR!");
                }
            }];
          
            //        NSDictionary *infoDict = [NSDictionary dictionaryWithObject: @"Package number" forKey: @"Package Key"];
            //        localNotif.userInfo = infoDict;
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
        }
    }
    
//    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
//    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        if (!object){
//            NSLog(@"failed");
//        } else {
//            NSLog(@"successful");
//            NSLog(object[@"username"]);
//            UILocalNotification *localNotif = [[UILocalNotification alloc] init];
//            if (localNotif) {
//                localNotif.alertBody = [NSString stringWithFormat:@"Do you wanna help %@ pick up a package?", object[@"username"]];
//                localNotif.alertAction = @"Testing notification based on regions";
//                localNotif.applicationIconBadgeNumber = 1;
//                
//                //        NSDictionary *infoDict = [NSDictionary dictionaryWithObject: @"Package number" forKey: @"Package Key"];
//                //        localNotif.userInfo = infoDict;
//                [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
//            }
//        }
//    }];
    
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:region.identifier message:[NSString stringWithFormat:@("Welcome to %@"), region.identifier] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//    [alert show];
}

//- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
//{
//    [self logCoordinate: [NSString stringWithFormat:@"%@ exiting", region.identifier]];
////    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:region.identifier message:[NSString stringWithFormat:@("ByeBye %@"), region.identifier] delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
////    [alert show];
//}

- (void)logCoordinate: (NSString *)regionName
{
    NSLog(regionName);
    NSError *error;
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: nil];
            
            NSURL * url = [NSURL URLWithString:@"http://libero.parseapp.com/coord"];
            NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
            NSString * params = [NSString stringWithFormat:@"region=%@&lat=%f&lon=%f&username=%@",regionName, geoPoint.latitude, geoPoint.longitude, [MyUser currentUser].username];
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
            
            //    NSDictionary *mapData = [[NSDictionary alloc] initWithObjectsAndKeys: @"tester", @"name", nil];
            //    NSData *postData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:&error];
            //    [urlRequest setHTTPBody:postData];
            
            //    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
            
            NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSLog(error.description);
            }];
            [dataTask resume];
        }
    }];
    
//    NSLog(@"completed");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
//    if([segue.identifier isEqualToString:@"Map View Test"]) {
//        if([segue.destinationViewController isKindOfClass:[MapViewController class]]) {
//            NSLog(@"================Segueing===============");
//            MapViewController *mvc = [segue destinationViewController];
//            mvc.request = self.requests[self.myIndexPath.row];
//        }
//    }
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        self.myIndexPath = [self.tableView indexPathForCell:sender];
        if([segue.identifier isEqualToString:@"Image View Segue"]) {
            if([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
                NSLog(@"================Segueing===============");
                ImageViewController *ivc = [segue destinationViewController];
                ivc.request = self.requests[self.myIndexPath.row];
                NSLog([self.requests[self.myIndexPath.row] valueForKeyPath:@"objectId"]);
            }
        }
    }
    
}

//- (void)pickUpEmail: (NSIndexPath *)indexPath
//{
//    NSLog(@"pickup email");
//    NSError *error;
//    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: nil];
//    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
//    [query getObjectInBackgroundWithId:[self.requests[self.myIndexPath.row] valueForKeyPath:@"objectId"] block:^(PFObject *object, NSError *error) {
//        object[@"deliverer"] = [PFUser currentUser].username;
//        object[@"delivererId"] = [PFUser currentUser].objectId;
//        object[@"delivered"] = @"delivering";
//        [object saveInBackground];
//    }];
//    NSURL * url = [NSURL URLWithString:@"http://plex.parseapp.com/pickup_email"];
//    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
//    NSString * params = [NSString stringWithFormat:@"name=%@&number=%@",[MyUser currentUser].username, [MyUser currentUser].additional];
//    [urlRequest setHTTPMethod:@"POST"];
//    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    //    NSDictionary *mapData = [[NSDictionary alloc] initWithObjectsAndKeys: @"tester", @"name", nil];
//    //    NSData *postData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:&error];
//    //    [urlRequest setHTTPBody:postData];
//    
//    //    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        NSLog(error.description);
//    }];
//    [dataTask resume];
//    NSLog(@"completed");
//}
@end
