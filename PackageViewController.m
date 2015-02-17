//
//  PackageViewController.m
//  LocationNotifier
//
//  Created by Yongsung on 10/6/14.
//  Copyright (c) 2014 NU. All rights reserved.
//

#import "PackageViewController.h"
#import <Parse/Parse.h>
#import "MyUser.h"
#import "AppDelegate.h"

@interface PackageViewController () <NSURLSessionDataDelegate>
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *residenceHall;
@property (weak, nonatomic) IBOutlet UILabel *carrier;
@property (weak, nonatomic) IBOutlet UILabel *packageType;
@property (weak, nonatomic) IBOutlet UILabel *trackingNumber;
@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, strong) NSString *userInfo;
@property (nonatomic, strong) NSString *delivererName;
@property (nonatomic, strong) NSString *delivererPhone;

@end

@implementation PackageViewController
- (IBAction)logOutButton:(UIBarButtonItem *)sender {
    [PFUser logOut];
    AppDelegate *appDelegateTemp = [[UIApplication sharedApplication]delegate];
    
    UIViewController* rootController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    
    UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:rootController];
    appDelegateTemp.window.rootViewController = navigation;
}

- (IBAction)deliveringButton:(UIButton *)sender {
    [self pickUpEmail];
    
    NSString *msg = [NSString stringWithFormat:@"Pick up notification has been sent to %@", self.userInfo];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmed!" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}



- (void)pickUpEmail
{
    NSError *error;
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: nil];
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query getObjectInBackgroundWithId:[self.request valueForKeyPath:@"objectId"] block:^(PFObject *object, NSError *error) {
        NSLog(object[@"username"]);
        object[@"deliverer"] = [PFUser currentUser].username;
        object[@"delivererId"] = [PFUser currentUser].objectId;
        [object saveInBackground];
    }];
    NSURL * url = [NSURL URLWithString:@"http://libero.parseapp.com/pickup_email"];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString * params = [NSString stringWithFormat:@"name=%@&number=%@&reqName=%@&email=%@",self.delivererName, self.delivererPhone, [self.request valueForKeyPath:@"username"], [self.request valueForKeyPath:@"email"]];
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
}

- (IBAction)cancelButton:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delivererName = [PFUser currentUser].username;
    self.delivererPhone = [MyUser currentUser].additional;
    NSLog([self.request valueForKeyPath:@"objectId"]);
    // Do any additional setup after loading the view.
    self.packageType.text = [NSString stringWithFormat:@"Package type: %@", [self.request valueForKeyPath:@"packageType"]];
    self.residenceHall.text = @"Residence hall: Seabury";
    //            self.title = [NSString stringWithFormat:@"You're at %@ Mail Room", objects[objects.count-1][@"mailRoom"]];
    self.userName.text = [NSString stringWithFormat:@"Package Recipient: \n%@", [self.request valueForKeyPath:@"username"]];
    self.userInfo = [self.request valueForKeyPath:@"username"];
    self.userName.numberOfLines = 0;
    [self.userName sizeToFit];
    self.carrier.text = [NSString stringWithFormat:@"%@ %@", self.carrier.text, [self.request valueForKeyPath:@"carrier"]];
    self.trackingNumber.text = [NSString stringWithFormat:@"Tracking Number: %@", [self.request valueForKeyPath:@"trackingNumber"]];
    self.trackingNumber.numberOfLines = 0;
    [self.trackingNumber sizeToFit];
//    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if(!error) {
////            for (PFObject *object in objects) {
////                if(object[@"carrier"]) {
////                    self.packageType.text = [NSString stringWithFormat:@"Package type: %@", object[@"packageType"]];
////                    self.residenceHall.text = @"Residence hall: Seabury";
////                    self.title = object[@"mailRoom"];
////                    self.userName.text = [NSString stringWithFormat:@"Name: \n%@", object[@"username"]];
////                    self.userName.numberOfLines = 0;
////                    [self.userName sizeToFit];
////                    self.carrier.text = [NSString stringWithFormat:@"%@ %@", self.carrier.text, object[@"carrier"]];
////                    self.trackingNumber.text = [NSString stringWithFormat:@"Tracking Number: %@", object[@"trackingNumber"]];
////                    self.trackingNumber.numberOfLines = 0;
////                    [self.trackingNumber sizeToFit];
////                }
////            }
//            self.packageType.text = [NSString stringWithFormat:@"Package type: %@", objects[objects.count-1][@"packageType"]];
//            self.residenceHall.text = @"Residence hall: Seabury";
//            //            self.title = [NSString stringWithFormat:@"You're at %@ Mail Room", objects[objects.count-1][@"mailRoom"]];
//            self.userName.text = [NSString stringWithFormat:@"Package Recipient: \n%@", objects[objects.count-1][@"username"]];
//            self.userInfo = objects[objects.count-1][@"username"];
//            self.userName.numberOfLines = 0;
//            [self.userName sizeToFit];
//            self.carrier.text = [NSString stringWithFormat:@"%@ %@", self.carrier.text, objects[objects.count-1][@"carrier"]];
//            self.trackingNumber.text = [NSString stringWithFormat:@"Tracking Number: %@", objects[objects.count-1][@"trackingNumber"]];
//            self.trackingNumber.numberOfLines = 0;
//            [self.trackingNumber sizeToFit];
//        }
//    }];
    
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
}


@end
