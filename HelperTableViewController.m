//
//  HelperTableViewController.m
//  LocationNotifier
//
//  Created by Yongsung on 10/14/14.
//  Copyright (c) 2014 NU. All rights reserved.
//

#import "HelperTableViewController.h"
#import "ESTBeaconManager.h"
#import "ESTBeacon.h"
#import <CoreMotion/CoreMotion.h>

#import "PackageViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "MyUser.h"
#import "ImageViewController.h"
#import "RWDropdownMenu.h"

@interface HelperTableViewController () <CLLocationManagerDelegate, UIAlertViewDelegate, ESTBeaconManagerDelegate>
@property (nonatomic, strong) NSArray *requests;
@property (nonatomic, strong) NSString *packageType;
@property (nonatomic, strong) NSString *username;

@property (nonatomic, strong) ESTBeaconManager  *beaconManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLCircularRegion *region;
@property (assign) BOOL notNotified;
@property (assign) CLLocationCoordinate2D currentLoc;
@property (strong, nonatomic) NSIndexPath *myIndexPath;
@property (nonatomic, strong) NSMutableArray *myHelpRequests;
@property (assign) BOOL beaconNoti;
@property (nonatomic, retain) CMMotionActivityManager *motionManager;
@property (assign) float heading;


@property (nonatomic, assign) RWDropdownMenuStyle menuStyle;


@end

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)

@implementation HelperTableViewController

//- (IBAction)indexChanged:(id)sender {
//    switch (self.segmentedControl.selectedSegmentIndex)
//    {
//        case 0:
//            [self HelperRequests];
//            [self.tableView reloadData];
//            break;
//        case 1:
//            [self MyHelpRequests];
//            [self appUsageLogging:@"myhelp"];
//            break;
//        default:
//            break;
//    }
//}

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


//- (void)testNotification
//{
//    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
//    // request object Id
////    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:objId forKey:objId];
////    localNotif.userInfo = dictionary;
//
//    if (localNotif) {
//        localNotif.alertBody = @"Help your friend to delivery package!";
//        localNotif.alertAction = @"Testing notification based on regions";
//        localNotif.applicationIconBadgeNumber = 1;
//        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
//    }
//}


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
    [self.tableView reloadData];
}

- (void)setUsername:(NSString *)username
{
    [self.tableView reloadData];
}

- (void)HelperRequests
{
    NSLog(@"Index : %d", [self.navigationController.viewControllers indexOfObject:self]);
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *tmpRequest = [[NSMutableArray alloc] init];
        
        if(!error) {
            for(PFObject *object in objects){
//FIXME: commented [(NSString *)object[@"residenceHall"] isEqualToString:(NSString *)[MyUser currentUser].residenceHall] or testing purpose
                if(![(NSString *)object[@"username"] isEqualToString:(NSString *)[MyUser currentUser].username] && ![object[@"delivered"] isEqualToString:@"delivered"] && ![object[@"delivered"] isEqualToString:@"delivering"]&& ![(NSString *)object[@"cancelled"] isEqualToString:@"cancelled"]) {
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
      [RWDropdownMenuItem itemWithText:@"Chat Sessions" image:nil action:^{
          UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"chatNav"];
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
      [RWDropdownMenuItem itemWithText:@"New Request" image:nil action:^{
          UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"addRequestNav"];
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
    [titleButton setTitle:@"Other's Requests" forState:UIControlStateNormal];
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
    self.locationManager.distanceFilter = 50;

    [self.locationManager startUpdatingLocation];
    
    CLLocationCoordinate2D plex; //Foster Walker
    plex.latitude = 42.053666;
    plex.longitude = -87.677672;
    CLCircularRegion *plexRegion = [[CLCircularRegion alloc] initWithCenter:plex radius:50 identifier:@"Plex"];
    [self.locationManager startMonitoringForRegion:self.region];
    
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter addObserver:self selector:@selector(appDidEnterForeground) name:@"appDidEnterForeground" object:nil];
    [self appUsageLogging:@"appopen"];
    
    NSUUID *uuid = [[NSUUID alloc]initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    //    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"sample" secured:YES];
    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid
                                                                       major: 56412
                                                                       minor: 31995
                                                                  identifier: @"iBeaconRegion"];
    [self.beaconManager requestWhenInUseAuthorization];
    [self.beaconManager startMonitoringForRegion:region];
    [self.beaconManager startRangingBeaconsInRegion:region];
    self.motionManager = [[CMMotionActivityManager alloc] init];
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
    cell.textLabel.text = [NSString stringWithFormat: @"Requester: %@", [request valueForKeyPath:@"username"]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMMM d, YYYY hh:mm a";
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"CST"];
    NSString *dateWithNewFormat = [dateFormatter stringFromDate:[request valueForKeyPath:@"createdAt"]];

    cell.detailTextLabel.text = [NSString stringWithFormat:@"Package Size: %@\nRequested at: %@", [request valueForKeyPath:@"packageType"], dateWithNewFormat];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Are you gonna pick this up?" message:@"If you click YES, email notification will be sent to the recipient." delegate:self cancelButtonTitle:@"NO" otherButtonTitles: nil];
    [alert addButtonWithTitle:@"YES"];
    [alert show];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex!= alertView.cancelButtonIndex){
//        [self performSegueWithIdentifier:@"Image View Segue" sender:self];
        NSLog(@"clicked okay");
        if (self.myIndexPath!=nil) {
            [self pickUpEmail:self.myIndexPath];
        }
    } else {
        self.myIndexPath = nil;
    }
}

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

#pragma mark - Location
- (void)getHeadingForDirectionFromCoordinate:(CLLocationCoordinate2D)fromLoc toCoordinate:(CLLocationCoordinate2D)toLoc
{
    float fLat = degreesToRadians(fromLoc.latitude);
    float fLng = degreesToRadians(fromLoc.longitude);
    float tLat = degreesToRadians(toLoc.latitude);
    float tLng = degreesToRadians(toLoc.longitude);
    
    float degree = radiandsToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    
    if (degree >= 0) {
        self.heading = degree;
        NSLog(@"degree is %f", degree);
        if (self.heading >= 90.0) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Heading" message:@"South" delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//            [alert show];
            NSLog(@"South");
        } else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Heading" message:@"North" delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//            [alert show];
            NSLog(@"North");
            
        }
    } else {
        self.heading = degree;
        NSLog(@"degree is %f", degree);
        if (self.heading <= -90.0) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Heading" message:@"South" delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//            [alert show];
            NSLog(@"South");
        } else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Heading" message:@"North" delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//            [alert show];
            NSLog(@"North");
            
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    CLLocation *locA = newLocation;
    CLLocation *locB = oldLocation;
    CLLocationCoordinate2D centerA;
    CLLocationCoordinate2D centerB;
    centerA.latitude = locA.coordinate.latitude;
    centerB.latitude = locB.coordinate.latitude;
    centerA.longitude = locA.coordinate.longitude;
    centerB.longitude = locB.coordinate.longitude;
    [self getHeadingForDirectionFromCoordinate:centerB toCoordinate:centerA];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    //FIXME: this is for v1
//    [self logCoordinate:region.identifier];
//    NSLog(@"Welcome to %@", region.identifier);
////    NSLog([self.requests[0] valueForKeyPath:@"username"]);
//    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
//    if ([self.requests count]>0){
//        if (localNotif) {
//            NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[self.requests[0] valueForKeyPath:@"objectId"] forKey:[self.requests[0] valueForKeyPath:@"objectId"]];
//            localNotif.userInfo = dictionary;
//            NSLog(@"%@", [self.requests[0] valueForKeyPath:@"packageType"]);
//            if ([self.requests[0] valueForKeyPath:@"packageType"] == NULL)
//                localNotif.alertBody = [NSString stringWithFormat:@"Hi %@! Can you pick up a package for me? --%@", [MyUser currentUser].username, [self.requests[0] valueForKeyPath:@"username"]];
//            else
//                localNotif.alertBody = [NSString stringWithFormat:@"Hi %@! Can you pick up a package (%@ lbs) for me? --%@", [MyUser currentUser].username, [self.requests[0] valueForKeyPath:@"packageType"], [self.requests[0] valueForKeyPath:@"username"]];
//            localNotif.alertAction = @"Testing notification based on regions";
//            localNotif.soundName = UILocalNotificationDefaultSoundName;
//            localNotif.applicationIconBadgeNumber = 1;
//            
//            PFQuery *query = [MyUser query];
//            [query getObjectInBackgroundWithId:[MyUser currentUser].objectId block:^(PFObject *object, NSError *error) {
//                if (!error) {
//                    int notifCount = [object[@"notifNum"] intValue];
//                    NSLog(@"%d", notifCount);
//                    NSNumber *value = [NSNumber numberWithInt:notifCount+1];
//                    object[@"notifNum"] = value;
//                    [object saveInBackground];
//                } else {
//                    NSLog(@"ERROR!");
//                }
//            }];
//          
//            //        NSDictionary *infoDict = [NSDictionary dictionaryWithObject: @"Package number" forKey: @"Package Key"];
//            //        localNotif.userInfo = infoDict;
//            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
//        }
//    }
    
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
//    NSLog(regionName);
//    NSError *error;
//    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
//        if (!error) {
//            NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
//            NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: nil];
//            
//            NSURL * url = [NSURL URLWithString:@"http://libero.parseapp.com/coord"];
//            NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
//            NSString * params = [NSString stringWithFormat:@"region=%@&lat=%f&lon=%f&username=%@",regionName, geoPoint.latitude, geoPoint.longitude, [MyUser currentUser].username];
//            [urlRequest setHTTPMethod:@"POST"];
//            [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
//            
//            //    NSDictionary *mapData = [[NSDictionary alloc] initWithObjectsAndKeys: @"tester", @"name", nil];
//            //    NSData *postData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:&error];
//            //    [urlRequest setHTTPBody:postData];
//            
//            //    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
//            
//            NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//                NSLog(error.description);
//            }];
//            [dataTask resume];
//        }
//    }];
//    
////    NSLog(@"completed");
}

- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    ESTBeacon *firstBeacon = [beacons firstObject];
    //    NSLog(@"%f", [firstBeacon.distance floatValue]);
    NSString *message = [NSString stringWithFormat:@"Hi %@! You are within %.02f meters to Delta lab, can you deliver an item from Delta lab to Frances Searle for me?", [MyUser currentUser].username, [firstBeacon.distance floatValue]];
    //    [self updateDotPositionForDistance:[firstBeacon.distance integerValue]];
    if (!self.beaconNoti && [firstBeacon.distance integerValue] < 3 && [firstBeacon.distance integerValue]!= -1 && [firstBeacon.distance integerValue]!= 0) {
        [self triggerNotificationWithMessage: message];
        NSLog(@"%@", message);
        self.beaconNoti = YES;
        [self appUsageLogging:[firstBeacon.distance stringValue]];
    }
}
//
- (void)beaconManager:(ESTBeaconManager *)manager didExitRegion:(ESTBeaconRegion *)region {
    //    self.beaconNoti = NO;
}

- (void)beaconManager:(ESTBeaconManager *)manager rangingBeaconsDidFailForRegion:(ESTBeaconRegion *)region withError:(NSError *)error {
    NSLog(error.description);
}


- (void)triggerNotificationWithMessage: (NSString *)message {
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = message;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    //    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]applicationIconBadgeNumber]+1;
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"========here here ======");
    // Get the new view controller using [segue destinationViewController].
//    if ([sender isKindOfClass:[UITableViewCell class]]) {
    self.myIndexPath = [self.tableView indexPathForCell:sender];
    if([segue.identifier isEqualToString:@"Image View Segue"]) {
        if([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
            NSLog(@"================Segueing===============");
            ImageViewController *ivc = [segue destinationViewController];
            ivc.request = self.requests[self.myIndexPath.row];
            NSLog([self.requests[self.myIndexPath.row] valueForKeyPath:@"objectId"]);
        }
    }
//    }
}

- (void)pickUpEmail: (NSIndexPath *)indexPath
{
    NSLog(@"pickup email");
    NSError *error;
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: nil];
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query getObjectInBackgroundWithId:[self.requests[self.myIndexPath.row] valueForKeyPath:@"objectId"] block:^(PFObject *object, NSError *error) {
        object[@"deliverer"] = [MyUser currentUser].username;
        object[@"delivererId"] = [MyUser currentUser].objectId;
        object[@"delivered"] = @"delivering";
        [object saveInBackground];
    }];
    
    NSURL * url = [NSURL URLWithString:@"http://libero.parseapp.com/pickup_email"];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *reqName = [self.requests[self.myIndexPath.row] valueForKeyPath:@"objectId"];
    NSString *name = [MyUser currentUser].username;
    NSString *email = [MyUser currentUser].email;
    NSLog(@"email=%@",email);
    NSString * params = [NSString stringWithFormat:@"name=%@&email=%@&reqName=%@",name,email,reqName];
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
    NSLog(@"completed");
    [self performSegueWithIdentifier:@"Image View Segue" sender:self];
}
@end
