//
//  AppDelegate.m
//  LocationNotifier
//
//  Created by Yongsung on 10/2/14.
//  Copyright (c) 2014 NU. All rights reserved.
//

#import "AppDelegate.h"
#import "PackageViewController.h"
#import <Parse/Parse.h> 
#import "MyUser.h"
#import "ESTConfig.h"
#import "ChatWallViewController.h" 
#import "CurrentPickUpTableViewController.h"
#import "MySession.h"
#import "AppealerTableViewController.h"
#define mySession [MySession sharedManager]

@interface AppDelegate () <CLLocationManagerDelegate>
@property (nonatomic, strong) UIStoryboard *storyBoard;

@end

@implementation AppDelegate
@synthesize cwvc;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [MyUser registerSubclass];
    [Parse setApplicationId:@"gnB2zH2cX8g0Nt5zpWTqmiXx3FSloF98QxhvOuvG" clientKey:@"dv90lyOLj3VzxscTnIuH9hRkUgds54hXWJz7gsR2"];
    [ESTConfig setupAppID:@"app_2kmj1w2otd" andAppToken:@"2c138ec1f40d00cbaebd2aaac6cf09a8"];

    if([MyUser currentUser]) {

    } else {
        UIViewController* rootController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SignInViewController"];
        UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:rootController];
        self.window.rootViewController = navigation;
    }
//    if(!self.storyBoard) self.storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    if(!self.mvc) self.mvc = [self.storyBoard instantiateViewControllerWithIdentifier:@"MapView"];

    //Register for Local Notifications
//    
//    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
//        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
//    }
//    
//     Register for Push Notitications, if running iOS 8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
////    currentInstallation[@"user"] = [MyUser currentUser].objectId;
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
//    NSLog(@"didregisternotif called");
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState applicationState = application.applicationState;
    if (applicationState == UIApplicationStateInactive || applicationState == UIApplicationStateBackground) {
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
        [application presentLocalNotificationNow:notification];
//        self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    }
    if(application.applicationState == UIApplicationStateActive ) {
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Local Notification" message:@"Inside" delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
//        [alert show];
        //The application received a notification in the active state, so you can display an alert view or do something appropriate.
    }
//    [[self window] makeKeyAndVisible];
//    self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
//    NSString *packageName = [notification.userInfo objectForKey:@"Package Key"];
//    MapViewController *mvc = [self.storyBoard instantiateViewControllerWithIdentifier:@"MapVC"];
//    [self.window.rootViewController performSegueWithIdentifier:@"Map View Segue" sender: self.window.rootViewController];
    //    self.window.rootViewController = self.mvc;
//    NSLog(@"%@", self.window.rootViewController);
//    [self.window.rootViewController performSegueWithIdentifier:@"PackageViewSegue" sender:self.window.rootViewController];
//    [self.window.rootViewController presentModalViewController:pvc animated:NO];
    application.applicationIconBadgeNumber = notification.applicationIconBadgeNumber - 1;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"objectId: %@ - whereFrom: %@", [userInfo valueForKeyPath:@"objectId"], [userInfo valueForKeyPath:@"whereFrom"]);
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if ([[userInfo valueForKeyPath:@"objectId"] isEqualToString:@"-1"]){
        //send to my requests
        
    } else if ([[userInfo valueForKeyPath:@"whereFrom"] isEqualToString:@"pickup"]) {
        NSDictionary *request = [userInfo valueForKeyPath:@"request"];
        
        UINavigationController *myNav = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"requestsNav"];
        self.window.rootViewController = myNav;
        AppealerTableViewController *atvc = (AppealerTableViewController *)[sb instantiateViewControllerWithIdentifier:@"MyRequestsVC"];
        
        // ChatWallViewController *cvc = (ChatWallViewController *)[sb instantiateViewControllerWithIdentifier:@"ChatWallViewController"];
        ChatWallViewController *cvc = [mySession cwvc];
        cvc.other = [NSString stringWithFormat:@"%@", [request valueForKeyPath:@"username"]];
        cvc.detailChat = YES;
        cvc.request = request;
        cvc.objId = [request valueForKey:@"objectId"];
        myNav.viewControllers = [NSArray arrayWithObjects:atvc,cvc, nil];
        [myNav popToViewController:cvc animated:YES];

        
    } else {
        //send to current pickups chat
        NSDictionary *request = [userInfo valueForKeyPath:@"request"];

        UINavigationController *myNav = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"currentPickupNav"];
        self.window.rootViewController = myNav;
        CurrentPickUpTableViewController *cptvc = (CurrentPickUpTableViewController *)[sb instantiateViewControllerWithIdentifier:@"CurrentPickUpTableViewController"];
        
       // ChatWallViewController *cvc = (ChatWallViewController *)[sb instantiateViewControllerWithIdentifier:@"ChatWallViewController"];
        ChatWallViewController *cvc = [mySession cwvc];
        cvc.other = [NSString stringWithFormat:@"%@", [request valueForKeyPath:@"username"]];
        cvc.detailChat = YES;
        cvc.request = request;
        cvc.objId = [request valueForKey:@"objectId"];
        myNav.viewControllers = [NSArray arrayWithObjects:cptvc,cvc, nil];
        [myNav popToViewController:cvc animated:YES];
    }
    
//    [PFPush handlePush:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotification:[NSNotification notificationWithName:@"appDidEnterForeground" object:nil]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
