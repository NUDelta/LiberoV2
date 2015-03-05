//
//  ChatWallViewController.m
//  Libero
//
//  Created by Shana Azria Dev on 2/17/15.
//  Copyright (c) 2015 YK. All rights reserved.
//

#import "ChatWallViewController.h"
#import "ChatDetailTableViewController.h"
#import "MyUser.h"
#import "ViewController.h"
#import "MySession.h"
#define mySession [MySession sharedManager]

@interface ChatWallViewController () <UIAlertViewDelegate>

@end
NSString * tmpNames;

@implementation ChatWallViewController
@synthesize other;
@synthesize detailChat;
@synthesize objId;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.messageInput.delegate = self;
    [self.messageInput setReturnKeyType:UIReturnKeyDone];
    [mySession setCwvc:self];
    
    if ([self.other isEqualToString:@"notdelivered"]){
        UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"requestsNav"];
        myNav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:myNav animated:YES completion:nil];
    } else {
        NSLog(@"%@", self.childViewControllers);
        NSLog(@"sender - %@ / receiver - %@", [PFUser currentUser].username, other);
        /* if (self.detailChat == nil) {
         self.detailChat = NO;
         }*/
        if (self.detailChat) {
            self.deliveredBttn.hidden = false;
        } else {
            self.deliveredBttn.hidden = true;
        }
        // Do any additional setup after loading the view.
    }
   
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.messageInput resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //NSString * tmpNames;
    if ((NSComparisonResult)[[PFUser currentUser].username compare: other] == NSOrderedAscending) {
        tmpNames = [NSString stringWithFormat: @"%@%@", [PFUser currentUser].username, other];
        
    } else {
         tmpNames = [NSString stringWithFormat: @"%@%@", other, [PFUser currentUser].username];
    }
    
    NSLog(tmpNames);
    if ([segue.identifier isEqualToString:@"chat2"]) {
        ViewController *vc = segue.destinationViewController;
        vc.combNames = tmpNames; // You can pass any value from A to B here
    }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)pushNotification {
    PFQuery *userQuery = [MyUser query];
   
    if ([[MyUser currentUser].username isEqualToString:[self.request valueForKeyPath:@"username"]]) {
        [userQuery whereKey:@"username" equalTo:[self.request valueForKeyPath:@"deliverer"]];
    } else {
        [userQuery whereKey:@"username" equalTo:[self.request valueForKeyPath:@"username"]];
    }
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" matchesQuery:userQuery];
    //            [pushQuery whereKey:@"user" equalTo:[object valueForKeyPath:@"objectId"]];
    PFPush *push = [[PFPush alloc]init];
    NSLog(@"here!");
    NSString *pushMsg = [[NSString alloc]initWithFormat:@"You've got a message from %@", [MyUser currentUser].username];
    NSDictionary *data;
    if (self.detailChat) {
        data = [NSDictionary dictionaryWithObjectsAndKeys: pushMsg, @"alert", @"cheering.caf", @"sound",[self.request valueForKeyPath:@"objectId"], @"objectId", @"pickup", @"whereFrom", self.request, @"request", nil];
    } else {
        data = [NSDictionary dictionaryWithObjectsAndKeys: pushMsg, @"alert", @"cheering.caf", @"sound",[self.request valueForKeyPath:@"objectId"], @"objectId", @"request", @"whereFrom", self.request, @"request", nil];
    }
    
    [push setQuery:pushQuery];
    [push setData:data];
    [push sendPushInBackground];
}

- (IBAction)sendMessage:(id)sender {
   // self.messageInput.text
    NSLog(@"%@", self.childViewControllers);
    ViewController *vc = [self.childViewControllers objectAtIndex:0];
    PFObject *obj = [PFObject objectWithClassName:@"ChatMessages"];
    [obj setObject:[MyUser currentUser].username forKey:@"sender"];
    [obj setObject:other forKey:@"receiver"];
    [obj setObject:tmpNames forKey:@"combinedNames"];
    [obj setObject:self.messageInput.text forKey:@"message"];
    [obj saveInBackground];
    self.messageInput.text = @"";
    [vc dataReloaded];
    [self pushNotification];
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
        //cancel clicked ...do your action
    }else{
        //yes clicked
        PFObject *point = [PFObject objectWithoutDataWithClassName:@"Message" objectId:self.objId];
        [point setObject:@"delivered" forKey:@"delivered"];
        [point save];
        UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"currentPickupNav"];
        myNav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:myNav animated:YES completion:nil];
        [self deliveredEmail];
        [self appUsageLogging: [NSString stringWithFormat:@"delivered %@", self.objId]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Package Delivered!"
                                                        message: @"Thanks for delivering the package!"
                                                       delegate: self
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil,nil];
        [alert show];
    }
}

- (void)deliveredEmail
{
    PFQuery *userQuery = [MyUser query];
    NSLog(@"testing: %@",[self.request valueForKeyPath:@"username"]);
    [userQuery whereKey:@"username" equalTo:[self.request valueForKeyPath:@"username"]];
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" matchesQuery:userQuery];
    //            [pushQuery whereKey:@"user" equalTo:[object valueForKeyPath:@"objectId"]];
    PFPush *push = [[PFPush alloc]init];
    NSLog(@"here!");
    NSString *pushMsg = [[NSString alloc]initWithFormat:@"Hi %@, I just delivered up your package!\n--%@", [self.request valueForKeyPath:@"username"], [MyUser currentUser].username];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys: pushMsg, @"alert", @"cheering.caf", @"sound",@"-1", @"objectId", @"delivered", @"whereFrom", @"-1", @"request", nil];
    [push setQuery:pushQuery];
    [push setData:data];
    [push sendPushInBackground];
    
    NSError *error;
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: nil];
    
    NSURL * url = [NSURL URLWithString:@"http://libero.parseapp.com/delivered_email"];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *reqName = [self.request valueForKeyPath:@"username"];
    NSString *name = [MyUser currentUser].username;
    NSString *email = [self.request valueForKeyPath:@"email"];
    NSString *reqObjId = [self.request valueForKeyPath:@"objectId"];
    
    [self appUsageLogging:[NSString stringWithFormat:@"picked up %@ package %@", reqName, reqObjId]];
    
    NSLog(@"email=%@",email);
    NSLog(@"name=%@",name);
    NSLog(@"requester name=%@", reqName);
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
    //    PFQuery *userQuery = [MyUser query];
    //    [userQuery whereKey:@"username" equalTo:[self.request valueForKeyPath:@"username"]];
    //    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
    //        self.reqObjectId = [object valueForKeyPath:@"objectId"];
    //        NSLog(@"testing pick up user %@", self.reqObjectId);
    //    }];
}

- (void)appUsageLogging: (NSString *)activity {
    PFObject *usage = [PFObject objectWithClassName:@"UsageLog"];
    usage[@"username"] = [MyUser currentUser].username;
    usage[@"userid"] = [MyUser currentUser].objectId;
    usage[@"activity"] = activity;
    [usage saveInBackground];
}

- (IBAction)deliveredPressed:(id)sender {
    [self appUsageLogging:[NSString stringWithFormat:@"delivered %@",objId]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delivered?"
                                                    message:@"Do you confirm this package has been delivered?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Yes", nil];
    
    [alert show];
}
@end
