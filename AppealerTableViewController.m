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

#import "ESTBeaconManager.h"
#import "ESTBeacon.h"
#import <CoreMotion/CoreMotion.h>
#import "PackageViewController.h"

@interface AppealerTableViewController () <UIAlertViewDelegate, UITableViewDelegate, ESTBeaconManagerDelegate, CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) NSMutableArray *myRequests;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, assign) RWDropdownMenuStyle menuStyle;

@property (nonatomic, strong) NSArray *helpRequests;
@property (nonatomic, strong) NSString *packageType;
@property (nonatomic, strong) NSString *username;

@property (nonatomic, strong) ESTBeaconManager  *beaconManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLCircularRegion *region;
@property (assign) BOOL notNotified;
@property (assign) CLLocationCoordinate2D currentLoc;
@property (strong, nonatomic) NSIndexPath *myIndexPath;
@property (nonatomic, strong) NSMutableArray *requests;
@property (assign) BOOL beaconNoti;
@property (nonatomic, retain) CMMotionActivityManager *motionManager;
@property (assign) float heading;
@property (nonatomic, strong) NSString *direction;
@property (nonatomic, strong) NSString *motion;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *notificationSetting;
@property (nonatomic, strong) UILocalNotification *localNotif;
@property (nonatomic, strong) NSString *group;

@end

@implementation AppealerTableViewController
#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)

- (IBAction)logOutButton:(UIBarButtonItem *)sender {
    [PFUser logOut];
    AppDelegate *appDelegateTemp = [[UIApplication sharedApplication]delegate];
    
    UIViewController* rootController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    
    UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:rootController];
    appDelegateTemp.window.rootViewController = navigation;
}

- (void)startDownloadMyRequest
{
    
    NSMutableArray *tmpRequest = [[NSMutableArray alloc]init];
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            for (PFObject *object in objects) {
//                NSLog((NSString *)object[@"username"]);
                if([(NSString *)object[@"username"] isEqualToString:(NSString *)[MyUser currentUser].username] && ![(NSString *)object[@"cancelled"] isEqualToString:@"true"]){
                    [tmpRequest addObject: object];
//                    NSLog(@"object added");
                }
            }
        }
        self.myRequests = tmpRequest;
        [self.tableView reloadData];
        
    }];
    if (self.refreshControl) {
        
        
        [self.refreshControl endRefreshing];
    }
    
}

- (void)HelperRequests
{
//    NSLog(@"Index : %d", [self.navigationController.viewControllers indexOfObject:self]);
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *tmpRequest = [[NSMutableArray alloc] init];
        
        if(!error) {
            for(PFObject *object in objects){
                if(![(NSString *)object[@"username"] isEqualToString:(NSString *)[MyUser currentUser].username] && ![object[@"delivered"] isEqualToString:@"delivered"] && ![object[@"delivered"] isEqualToString:@"picked up"]&& ![(NSString *)object[@"cancelled"] isEqualToString:@"true"]) {
//                    NSLog(@"%@", object[@"residenceHall"]);
//                    NSLog(@"another one %@", [MyUser currentUser].residenceHall);
                    [tmpRequest addObject: object];
                }
            }
        }
        self.requests = tmpRequest;
        NSLog(@"%d",self.requests.count);
        if (self.requests.count > 0) {
            if ([self.requests[self.requests.count -1] valueForKeyPath:@"packageType"] == NULL)
                self.message = [NSString stringWithFormat:@"Hi %@! Can you pick up a package for me? --%@", [MyUser currentUser].username], [self.requests[0] valueForKeyPath:@"username"];
            else
                self.message = [NSString stringWithFormat:@"Hi %@! Can you pick up a package (%@ size) for me? --%@", [MyUser currentUser].username, [self.requests[0] valueForKeyPath:@"packageType"], [self.requests[0] valueForKeyPath:@"username"]];
        }
    }];
}

- (void)presentStyleMenu:(id)sender
{
    NSArray *styleItems =
    @[
      [RWDropdownMenuItem itemWithText:@"My Requests" image:nil action:^{
          UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"requestsNav"];
          myNav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
          [self presentViewController:myNav animated:YES completion:nil];
          self.menuStyle = RWDropdownMenuStyleTranslucent;
      }],
      [RWDropdownMenuItem itemWithText:@"Current Pickups" image:nil action:^{
          UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"currentPickupNav"];
          myNav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
          [self presentViewController:myNav animated:YES completion:nil];
          self.menuStyle = RWDropdownMenuStyleTranslucent;
      }],
      [RWDropdownMenuItem itemWithText:@"Others' Requests" image:nil action:^{
          UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"friendR"];
          myNav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
          [self presentViewController:myNav animated:YES completion:nil];
          self.menuStyle = RWDropdownMenuStyleBlackGradient;
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

    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self action:@selector(startDownloadMyRequest)forControlEvents:UIControlEventValueChanged];
    self.navigationController.navigationBarHidden=NO;
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [titleButton setImage:[[UIImage imageNamed:@"down@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [titleButton setTitle:@"My Requests" forState:UIControlStateNormal];
    [titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
    [titleButton addTarget:self action:@selector(presentStyleMenu:) forControlEvents:UIControlEventTouchUpInside];
    [titleButton setTintColor:[UIColor blackColor]];
    [titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [titleButton sizeToFit];
    self.navigationItem.titleView = titleButton;
    
    UINavigationItem *navItem = self.navigationItem;
    navItem.title = @"My Requests";
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem)];
    navItem.rightBarButtonItem = bbi;
    navItem.leftBarButtonItem = self.editButtonItem;
    [navItem.rightBarButtonItem setTintColor:[UIColor blackColor]];
    [navItem.leftBarButtonItem setTintColor:[UIColor blackColor]];
    //    NSLog([PFUser currentUser].username);
    [self startDownloadMyRequest];
    
    [self HelperRequests];
    
    self.direction = [[NSString alloc]init];
    self.message = [[NSString alloc]init];
    self.direction = @"south";
    
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    NSLog(@"current hour is: %d", hour);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    //    [notifCenter addObserver:self selector:@selector(appDidEnterForeground) name:@"appDidEnterForeground" object:nil];
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
    self.locationManager.distanceFilter = 10;
    
    [self.locationManager startUpdatingLocation];
    
    CLLocationCoordinate2D center; //Ford
    center.latitude = 42.056929;
    center.longitude = -87.676519;
    
    CLLocationCoordinate2D plex; //coffee lab
    plex.latitude = 42.058275;
    plex.longitude = -87.684179;
    
    CLCircularRegion *plexRegion = [[CLCircularRegion alloc] initWithCenter:plex radius:100 identifier:@"Plex"];
    [self.locationManager startMonitoringForRegion: plexRegion];
    
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter addObserver:self selector:@selector(appDidEnterForeground) name:@"appDidEnterForeground" object:nil];
    
    [notifCenter addObserver:self selector: @selector(notificationChanged:) name:@"notificationChanged" object: nil];
//    [self appUsageLogging:@"appopen"];
    
    NSUUID *uuid = [[NSUUID alloc]initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    NSUUID *uuid_purple = [[NSUUID alloc]initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    
    //    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"sample" secured:YES];
    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid
                                                                       major: 56412
                                                                       minor: 31995
                                                                  identifier: @"Rolling"];
    
    ESTBeaconRegion* regionPurple = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid
                                                                             major: 16165
                                                                             minor: 62862
                                                                        identifier: @"Coffee Lab"];
    
    NSUUID *uuid_blue = [[NSUUID alloc]initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    
    //    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"sample" secured:YES];
    ESTBeaconRegion* regionBlue = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid_blue
                                                                       major: 53852
                                                                       minor: 47788
                                                                  identifier: @"Als Deli"];
    
    NSUUID *uuid_purple_second = [[NSUUID alloc]initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    ESTBeaconRegion* regionPurpleSecond = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid_purple_second
                                                                           major: 28548
                                                                           minor: 7152
                                                                      identifier: @"Mandarin House"];
    
    NSUUID *uuid_green_second = [[NSUUID alloc]initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    
    //    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"sample" secured:YES];
    ESTBeaconRegion* regionGreenSecond = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid_green_second
                                                                                   major: 18034
                                                                                   minor: 56913
                                                                              identifier: @"DMK"];
    
    if ([self.beaconManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.beaconManager requestWhenInUseAuthorization];
    }
    
    [self.beaconManager startMonitoringForRegion:region];   //Rollin' to go
    [self.beaconManager startRangingBeaconsInRegion:region];
    
    [self.beaconManager startMonitoringForRegion:regionPurple]; // Coffee lab
    [self.beaconManager startRangingBeaconsInRegion:regionPurple];
    
    [self.beaconManager startMonitoringForRegion:regionBlue];   //Als Deli
    [self.beaconManager startRangingBeaconsInRegion:regionBlue];
    
    [self.beaconManager startMonitoringForRegion:regionPurpleSecond];   //Mandarin House
    [self.beaconManager startRangingBeaconsInRegion:regionPurpleSecond];
    
//    [self.beaconManager startMonitoringForRegion:regionGreenSecond];   //DMK burger
//    [self.beaconManager startRangingBeaconsInRegion:regionGreenSecond];
    
    
    
    self.motionManager = [[CMMotionActivityManager alloc] init];
    [self detectMotion];
    //    self.localNotif = [[UILocalNotification alloc] init];
}

- (void)appDidEnterForeground {
    [self startDownloadMyRequest];
    //    [self.tableView reloadData];
    [self HelperRequests];
    NSLog(@"did appear");
    PFQuery *query = [MyUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            for(PFObject *object in objects){
                if([(NSString *)object[@"username"] isEqualToString:(NSString *)[MyUser currentUser].username]) {
                    if (!object[@"notification"])
                        self.notificationSetting = @"On";
                    else
                        self.notificationSetting = object[@"notification"];
                    if (!object[@"group"])
                        self.group = @"ic";
                    else
                        self.group = object[@"group"];
                }
            }
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
//    NSLog(@"did appear");
    [self appUsageLogging:@"myrequest"];
    [self startDownloadMyRequest];
    
    //    [self.tableView reloadData];
//    NSLog(@"table View reloaded");
    PFQuery *query = [MyUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            for(PFObject *object in objects){
                if([(NSString *)object[@"username"] isEqualToString:(NSString *)[MyUser currentUser].username]) {
                    if (!object[@"notification"])
                        self.notificationSetting = @"On";
                    else
                        self.notificationSetting = object[@"notification"];
                    if (!object[@"group"])
                        self.group = @"jit";
                    else
                        self.group = object[@"group"];
                        
                }
            }
        }
    }];
    //    [self.tableView deselectRowAtIndexPath:self.myIndexPath animated:YES];
    [self HelperRequests];
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


#pragma mark - Location
- (void)notificationChanged: (NSNotification *)notification {
    NSLog(@"notification settings!!!!!!!!!!!!!!! %@", [notification.userInfo valueForKeyPath:@"notificationKey"]);
    self.notificationSetting = [notification.userInfo valueForKeyPath:@"notificationKey"];
    //    PFQuery *query = [MyUser query];
    //    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    //        if(!error) {
    //            for(PFObject *object in objects){
    //                if([(NSString *)object[@"username"] isEqualToString:(NSString *)[MyUser currentUser].username]) {
    //                    object[@"notification"] = [notification.userInfo valueForKeyPath:@"notificationKey"];
    //                    [object saveInBackground];
    //                }
    //            }
    //        }
    //    }];
}

- (void)detectMotion {
    if([CMMotionActivityManager isActivityAvailable]) {
        [self.motionManager startActivityUpdatesToQueue:[[NSOperationQueue alloc]init] withHandler:^(CMMotionActivity *activity) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (activity.walking) {
                    self.motion = @"walking";
                    //                        [self appUsageLogging:@"running"];
                }
                else if (activity.running) {
                    self.motion = @"running";
                    //                        [self appUsageLogging:@"running"];
                }
//                else {
//                    self.motion = @"walking";
//                }
            });
        }];
    }
}

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
            //            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Heading" message:@"South" delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
            //            [alert show];
            self.direction = @"south";
            [self appUsageLogging:@"south"];
            NSLog(@"South");
        } else {
            //            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Heading" message:@"North" delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
            //            [alert show];
            self.direction = @"north";
            [self appUsageLogging:@"north"];
            NSLog(@"North");
        }
    } else {
        self.heading = degree;
        NSLog(@"degree is %f", degree);
        if (self.heading <= -90.0) {
            //            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Heading" message:@"South" delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
            //            [alert show];
            self.direction = @"south";
            [self appUsageLogging:@"south"];
            NSLog(@"South");
        } else {
            //            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Heading" message:@"North" delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
            //            [alert show];
            self.direction = @"north";
            [self appUsageLogging:@"north"];
            NSLog(@"North");
            
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    //FIXME: this is for v1

//    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
//        if (!error) {
//            CLLocationCoordinate2D oldLoc;
//            oldLoc.latitude = geoPoint.latitude;
//            oldLoc.longitude = geoPoint.longitude;
//            CLLocationCoordinate2D plex;
//            plex.latitude = 42.052973;
//            plex.longitude = -87.678630;
//            [self getHeadingForDirectionFromCoordinate:oldLoc toCoordinate:plex];
//            NSString *str = [NSString stringWithFormat:@"Entered region %f, %f", oldLoc.latitude, oldLoc.longitude];
//            [self appUsageLogging:str];
//        }
//    }];
    
    NSLog(@"notification setting: %@", self.notificationSetting);
//    NSLog(@"this is the group name: %@", self.group);
    if ([region.identifier isEqualToString:@"Plex"]) {
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            if (!error) {
                NSString *message = [NSString stringWithFormat:@"Entered %f, %f",geoPoint.latitude, geoPoint.longitude];
                [self appUsageLogging:message];
            }
        }];
    }
    if ([self.group isEqualToString:@"ic"]){
        [self HelperRequests];
    }

    if (self.notificationSetting && [self.group isEqualToString:@"jit"]) {
//        NSLog(@"Welcome to %@", region.identifier);
        //    NSLog(@"notification setting: %@", self.notificationSetting);
//        NSLog(@"notification setting: %@", self.notificationSetting);
        if ([region.identifier isEqualToString:@"Plex"] && [self.notificationSetting isEqualToString:@"On"]) {
            UILocalNotification *localNotif = [[UILocalNotification alloc] init];
            PFQuery *query = [PFQuery queryWithClassName:@"Message"];
            NSMutableArray *tmpRequest = [[NSMutableArray alloc] init];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                for(PFObject *object in objects){
                    if(![(NSString *)object[@"username"] isEqualToString:(NSString *)[MyUser currentUser].username] && ![object[@"delivered"] isEqualToString:@"delivered"] && ![object[@"delivered"] isEqualToString:@"picked up"]&& ![(NSString *)object[@"cancelled"] isEqualToString:@"true"]) {
//                        NSLog(@"%@", object[@"residenceHall"]);
//                        NSLog(@"another one %@", [MyUser currentUser].residenceHall);
                        [tmpRequest addObject: object];
                    }
                }
                self.requests = tmpRequest;
                if ([self.requests count]>0){
                    if (localNotif) {
                        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[self.requests[0] valueForKeyPath:@"objectId"] forKey:[self.requests[0] valueForKeyPath:@"objectId"]];
                        localNotif.userInfo = dictionary;
                        NSLog(@"%@", [self.requests[0] valueForKeyPath:@"packageType"]);
                        if ([self.requests[0] valueForKeyPath:@"packageType"] == NULL)
                            localNotif.alertBody = [NSString stringWithFormat:@"Hi %@! Can you pick up a package for me? --%@", [MyUser currentUser].username, [self.requests[0] valueForKeyPath:@"username"]];
                        else
                            localNotif.alertBody = [NSString stringWithFormat:@"Hi %@! Can you pick up a package (%@ size) for me? --%@", [MyUser currentUser].username, [self.requests[0] valueForKeyPath:@"packageType"], [self.requests[0] valueForKeyPath:@"username"]];
                        localNotif.soundName = UILocalNotificationDefaultSoundName;
                        localNotif.applicationIconBadgeNumber = 1;
                        
                        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];

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
                    }
                }
            }];
        }
    }

}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if ([region.identifier isEqualToString:@"Plex"]) {
        self.beaconNoti = NO;
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            if (!error) {
                NSString *message = [NSString stringWithFormat:@"Exited %f, %f",geoPoint.latitude, geoPoint.longitude];
                [self appUsageLogging:message];
            }
        }];
    }
}


- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
//    if(self.requests.count > 0){
//        if ([self.requests[0] valueForKeyPath:@"packageType"] == NULL)
//            self.message = [NSString stringWithFormat:@"Hi %@! Can you pick up a package for me? --%@", [MyUser currentUser].username], [self.requests[0] valueForKeyPath:@"username"];
//        else
//            self.message = [NSString stringWithFormat:@"Hi %@! Can you pick up a package (%@ size) for me? --%@", [MyUser currentUser].username, [self.requests[0] valueForKeyPath:@"packageType"], [self.requests[0] valueForKeyPath:@"username"]];
//        ESTBeacon *firstBeacon = [beacons firstObject];
//        if (!self.beaconNoti && [firstBeacon.distance integerValue] < 80 && [firstBeacon.distance integerValue]!= -1 && [firstBeacon.distance floatValue]!= 0.0) {
//            NSLog(@"%@", [firstBeacon.distance stringValue]);
//            [self triggerNotificationWithMessage: self.message];
//            self.beaconNoti = YES;
//            [self appUsageLogging:[firstBeacon.distance stringValue]];
//        }
//    }
}

- (void)beaconManager:(ESTBeaconManager *)manager didEnterRegion:(ESTBeaconRegion *)region {
//    [self HelperRequests];
    if(self.requests.count > 0){
        if ([self.requests[0] valueForKeyPath:@"packageType"] == NULL)
            self.message = [NSString stringWithFormat:@"Hi %@! Can you pick up a package for me? --%@", [MyUser currentUser].username, [self.requests[0] valueForKeyPath:@"username"]];
        else
            self.message = [NSString stringWithFormat:@"Hi %@! Can you pick up a package (%@ size) for me? --%@", [MyUser currentUser].username, [self.requests[0] valueForKeyPath:@"packageType"], [self.requests[0] valueForKeyPath:@"username"]];
        if (!self.beaconNoti) {
            [self triggerNotificationWithMessage: self.message];
            self.beaconNoti = YES;
        }
    }
    NSString *message = [NSString stringWithFormat:@"Entered %@", region.identifier];
    [self appUsageLogging:message];
}


- (void)beaconManager:(ESTBeaconManager *)manager didExitRegion:(ESTBeaconRegion *)region {
    NSString *message = [NSString stringWithFormat:@"Exited %@", region.identifier];
    [self appUsageLogging:message];
}

- (void)beaconManager:(ESTBeaconManager *)manager rangingBeaconsDidFailForRegion:(ESTBeaconRegion *)region withError:(NSError *)error {
    NSLog(error.description);
}

- (void)triggerNotificationWithMessage: (NSString *)message {
    //TODO: test outside!
    self.direction = @"south";
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    NSLog(@"current hour is: %d", hour);
    BOOL isHour = NO;
    if (hour>=7 && hour <=19) {
        isHour = YES;
    }
    if ([self.direction isEqualToString:@"south"] && self.notificationSetting && [self.group isEqualToString:@"ic"] && isHour)
    {
        if ([self.motion isEqualToString:@"walking"] || [self.motion isEqualToString:@"running"]) {
            if ([self.motion isEqualToString:@"walking"])
                [self appUsageLogging:@"walking"];
            if ([self.motion isEqualToString:@"running"])
                [self appUsageLogging:@"running"];
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.alertBody = message;
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            //    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]applicationIconBadgeNumber]+1;
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
            [self appUsageLogging:@"notification"];
        }
//        else {
//            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//            localNotification.alertBody = message;
//            localNotification.soundName = UILocalNotificationDefaultSoundName;
//            //    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]applicationIconBadgeNumber]+1;
//            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
//        }
        PFQuery *query = [MyUser query];
        [query getObjectInBackgroundWithId:[MyUser currentUser].objectId block:^(PFObject *object, NSError *error) {
            if (!error) {
                int notifCount = [object[@"notifNum"] intValue];
                //                NSLog(@"%d", notifCount);
                NSNumber *value = [NSNumber numberWithInt:notifCount+1];
                object[@"notifNum"] = value;
                [object saveInBackground];
            } else {
                NSLog(@"ERROR!");
            }
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.myRequests count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *request = self.myRequests[self.myRequests.count - 1 - indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Appealer Request Cell" forIndexPath:indexPath];
    
    //    cell.textLabel.text = [NSString stringWithFormat:@"Tracking #: %@", [request valueForKeyPath:@"trackingNumber"]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMMM d, YYYY hh:mm a";
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"CST"];
    NSString *dateWithNewFormat = [dateFormatter stringFromDate:[request valueForKeyPath:@"createdAt"]];
    NSString *desc = ([request valueForKeyPath:@"itemDescription"] && ![[request valueForKey:@"itemDescription"] isEqualToString:@""]) ? [request valueForKeyPath:@"itemDescription"]: @"no description";
    cell.textLabel.text = [NSString stringWithFormat:@"Description: %@", desc];
    
    if([(NSString *)[request valueForKeyPath:@"deliverer"] isEqualToString:@"null"])
     cell.detailTextLabel.text = [NSString stringWithFormat:@"Status: %@\nSize: %@\nRequested at: %@",[request valueForKeyPath:@"delivered"],[request valueForKeyPath:@"packageType"], dateWithNewFormat];
    else
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Status: %@ by %@\nSize: %@\nRequested at: %@",[request valueForKeyPath:@"delivered"], [request valueForKeyPath:@"deliverer"],[request valueForKeyPath:@"packageType"], dateWithNewFormat];
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

- (void)tableView: (UITableView*)tableView
  willDisplayCell: (UITableViewCell*)cell
forRowAtIndexPath: (NSIndexPath*)indexPath
{
    if ([(NSString *)[self.myRequests[self.myRequests.count - 1 - indexPath.row] valueForKeyPath:@"delivered"] isEqualToString:@"delivered"]) {
        cell.backgroundColor = [UIColor colorWithRed: 114.0/255 green: 109.0/255 blue: 128.0/255 alpha: 1.0];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    } else {
        cell.backgroundColor = [UIColor colorWithRed: 46.0/255 green: 38.0/255 blue: 99.0/255 alpha: 0.5];;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    }
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"deleted");
        PFQuery *query = [PFQuery queryWithClassName:@"Message"];
        [query getObjectInBackgroundWithId:[self.myRequests[self.myRequests.count - 1 - indexPath.row] valueForKeyPath:@"objectId"] block:^(PFObject *object, NSError *error) {
            if(!error) {
                object[@"cancelled"] = @"true";
//                NSLog(@"requets count: %lu", (unsigned long)[self.myRequests count]);
                NSLog(@"%@", indexPath.description);
                [self.myRequests removeObjectAtIndex: self.myRequests.count - 1 - indexPath.row];
//                NSLog(@"requets count: %lu", (unsigned long)[self.myRequests count]);
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

-(BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    NSDictionary *request = self.myRequests[self.myRequests.count -1 - indexPath.row];
    if([(NSString *)[request valueForKeyPath:@"deliverer"] isEqualToString:@"null"]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Waiting for pickup"
                                                        message: @"We're sorry, your package hasn't been picked up yet!"
                                                       delegate: self
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil,nil];
        [alert show];
        return NO;
    } else {
        return YES;
    }
    
    
}
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    NSDictionary *request = self.myRequests[self.myRequests.count -1 - indexPath.row];
    
    NSLog(@"======================deliverer %@", [request valueForKeyPath:@"deliverer"]);
    if([(NSString *)[request valueForKeyPath:@"deliverer"] isEqualToString:@"null"]) {
        
       /* if([segue.identifier isEqualToString:@"chatV2"]) {
            if([segue.destinationViewController isKindOfClass:[ChatWallViewController class]]) {
                ChatWallViewController *cvc = [segue destinationViewController];
                NSLog(@"%@", [request valueForKeyPath:@"deliverer"]);
                cvc.other = @"notdelivered";
                cvc.detailChat = NO;
                //cvc.objId = [request valueForKey:@"objectId"];
                NSLog(@"segueing");
            }
        }*/
        
        
        
    } else if([sender isKindOfClass:[UITableViewCell class]]) {
        
        if([segue.identifier isEqualToString:@"chatV2"]) {
            if([segue.destinationViewController isKindOfClass:[ChatWallViewController class]]) {
                ChatWallViewController *cvc = [segue destinationViewController];
                NSLog(@"%@", [request valueForKeyPath:@"deliverer"]);
                cvc.other = [NSString stringWithFormat:@"%@", [request valueForKeyPath:@"deliverer"]];
                cvc.detailChat = NO;
                //cvc.objId = [request valueForKey:@"objectId"];
                cvc.request = request;
                NSLog(@"segueing");
                [self appUsageLogging:[NSString stringWithFormat:@"requester chat with %@ for %@", cvc.other, [request valueForKeyPath:@"objectId"]]];
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