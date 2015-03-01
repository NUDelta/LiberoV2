//
//  ImageViewController.m
//  Libero
//
//  Created by Yongsung on 11/9/14.
//  Copyright (c) 2014 NU. All rights reserved.
//

#import "ImageViewController.h"
#import <Parse/Parse.h>
#import "MyUser.h"

@interface ImageViewController () <UIScrollViewDelegate>
@property (nonatomic,strong) UIImage *image;
@property (strong, nonatomic) NSString *reqObjectId;
@property (weak, nonatomic) IBOutlet UILabel *thankLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ImageViewController
- (IBAction)pickUpButton:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Are you gonna pick this up?" message:@"If you click YES, email/sms notification will be sent to the recipient." delegate:self cancelButtonTitle:@"NO" otherButtonTitles: nil];
    [alert addButtonWithTitle:@"YES"];
    [alert show];
}
- (IBAction)dropOffButton:(UIButton *)sender {
    //    [self dropOffEmail];
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query getObjectInBackgroundWithId:[self.request valueForKeyPath:@"objectId"] block:^(PFObject *object, NSError *error) {
        object[@"delivered"] = @"delivered";
        [object saveInBackground];
    }];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Libero" message:@"Thank you for delivering the package!" delegate:self cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
    [alert show];
    
    [self appUsageLogging:@"dropoff"];
}

- (void)appUsageLogging: (NSString *)activity {
    PFObject *usage = [PFObject objectWithClassName:@"UsageLog"];
    usage[@"username"] = [MyUser currentUser].username;
    usage[@"userid"] = [MyUser currentUser].objectId;
    usage[@"activity"] = activity;
    [usage saveInBackground];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex!= alertView.cancelButtonIndex){
        PFQuery *query = [PFQuery queryWithClassName:@"Message"];
        [query getObjectInBackgroundWithId:[self.request valueForKeyPath:@"objectId"] block:^(PFObject *object, NSError *error) {
            object[@"deliverer"] = [MyUser currentUser].username;
            object[@"delivererId"] = [MyUser currentUser].objectId;
            object[@"delivered"] = @"delivering";
            [object saveInBackground];
        }];
        
        //        [self performSegueWithIdentifier:@"Map View Segue" sender:self];
        //        [self pickUpEmail];
        //        PFQuery *userQuery = [MyUser query];
        //        if(self.reqObjectId!=nil){
        //            [userQuery whereKey:@"objectId" equalTo:self.reqObjectId];
        //            PFQuery *pushQuery = [PFInstallation query];
        //            [pushQuery whereKey:@"user" matchesQuery:userQuery];
        //            //            [pushQuery whereKey:@"user" equalTo:[object valueForKeyPath:@"objectId"]];
        //            PFPush *push = [[PFPush alloc]init];
        //            NSString *pushMsg = [[NSString alloc]initWithFormat:@"Hi %@, I just picked up your package!\n--%@", [self.request valueForKeyPath:@"username"], [MyUser currentUser].username];
        //            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
        //                                  pushMsg, @"alert"
        //                                  @"cheering.caf", @"sound",
        //                                  nil];
        //            [push setQuery:pushQuery];
        //            [push setData:data];
        //            [push sendPushInBackground];
        //        }
        [self appUsageLogging:@"pickup"];
    } else {
    }
}

- (void)setScrollView:(UIScrollView *)scrollView {
    _scrollView = scrollView;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;
    self.scrollView.contentSize = self.image? self.image.size: CGSizeZero;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //    PFQuery *userQuery = [MyUser query];
    //    [userQuery whereKey:@"username" equalTo:[self.request valueForKeyPath:@"username"]];
    //    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
    //        self.reqObjectId = [object valueForKeyPath:@"objectId"];
    //        NSLog(@"testing pick up user %@", self.reqObjectId);
    //    }];
    // Do any additional setup after loading the view.
    self.thankLabel.text = [NSString stringWithFormat:@"Thanks for picking this up %@!", [MyUser currentUser].username];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    NSLog(@"here is request object id: %@", [self.request valueForKeyPath:@"objectId"]);
    [query getObjectInBackgroundWithId:[self.request valueForKeyPath:@"objectId"] block:^(PFObject *object, NSError *error) {
        if(!error) {
            NSLog(@"-------testing--------");
            NSLog(@"username here: %@", [object valueForKeyPath:@"username"]);
            NSLog(@"here is object id: %@", [object valueForKeyPath:@"objectId"]);
            PFFile *imageFile = object[@"image"];
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if(!error) {
                    self.image = [UIImage imageWithData: data];
                    self.imageView.image = self.image;
                    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
                    
                }
            }];
        } else {
            NSLog(@"error!");
        }
    }];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)dropOffEmail
{
    NSError *error;
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: nil            ];
    
    NSURL * url = [NSURL URLWithString:@"http://libero.parseapp.com/dropoff_email"];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString * params = [NSString stringWithFormat:@"name=%@&phone=%@&reqName=%@&email=%@",[MyUser currentUser].username, [MyUser currentUser].additional, [self.request valueForKeyPath:@"username"], [self.request valueForKeyPath:@"email"]];
    
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
    [self sendSMS:@"dropoff"];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Thank you for the delivery!" message:@"drop off notification has been sent to the recipient" delegate:nil cancelButtonTitle:@"OKAY" otherButtonTitles: nil];
    [alert show];
}

- (void)sendSMS: (NSString *)deliveryStatus
{
    PFQuery *userQuery = [MyUser query];
    [userQuery whereKey:@"username" equalTo:[self.request valueForKeyPath:@"username"]];
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            NSMutableDictionary * twilioParams = [[NSMutableDictionary alloc]init];
            twilioParams[@"helpNum"] = [MyUser currentUser].additional;
            twilioParams[@"helper"] = [MyUser currentUser].username;
            twilioParams[@"delivstatus"] = deliveryStatus;
            twilioParams[@"reqNum"] = [object valueForKeyPath:@"additional"];
            twilioParams[@"requester"] = [object valueForKeyPath:@"username"];
            [PFCloud callFunctionInBackground:@"sendSms"
                               withParameters:twilioParams
                                        block:^(id object, NSError *error) {
                                            NSLog(error.description);
                                        }];
        }
    }];
}

- (void)pickUpEmail
{
    NSLog(@"pickup email");
    NSError *error;
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: nil];
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query getObjectInBackgroundWithId:[self.request valueForKeyPath:@"objectId"] block:^(PFObject *object, NSError *error) {
        object[@"deliverer"] = [MyUser currentUser].username;
        object[@"delivererId"] = [MyUser currentUser].objectId;
        object[@"delivered"] = @"delivering";
        [object saveInBackground];
    }];
    NSURL * url = [NSURL URLWithString:@"http://libero.parseapp.com/pickup_email"];
    
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    //    NSString * params = [NSString stringWithFormat:@"name=%@&number=%@",[MyUser currentUser].username, [MyUser currentUser].additional];
    NSString * params = [NSString stringWithFormat:@"name=%@&number=%@&reqName=%@&email=%@",[MyUser currentUser].username, [MyUser currentUser].additional,[self.request valueForKeyPath:@"username"], [self.request valueForKeyPath:@"email"]];
    
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
    
    [self sendSMS:@"pickup"];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
@end
