//
//  DelivererViewController.m
//  LocationNotifier
//
//  Created by Yongsung on 10/14/14.
//  Copyright (c) 2014 NU. All rights reserved.
//

#import "DelivererViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "MyUser.h"

@interface DelivererViewController ()
@property (weak, nonatomic) IBOutlet UILabel *deliverer;
@property (nonatomic, strong) NSString *phoneNumber;
@property BOOL phoneNum;
@end

@implementation DelivererViewController
//- (IBAction)logOutButton:(UIBarButtonItem *)sender {
//    [PFUser logOut];
//    AppDelegate *appDelegateTemp = [[UIApplication sharedApplication]delegate];
//    
//    UIViewController* rootController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"LoginViewController"];
//    
//    UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:rootController];
//    appDelegateTemp.window.rootViewController = navigation;
//}

- (IBAction)callButton:(UIButton *)sender {
    if(self.phoneNum){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [NSString stringWithFormat:@"telprompt://%@", self.phoneNumber]]];
        [self appUsageLogging:@"call"];
    }
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
        [self appUsageLogging:@"cancelrequest"];
        PFQuery *query = [PFQuery queryWithClassName:@"Message"];
        [query getObjectInBackgroundWithId:[self.request valueForKeyPath:@"objectId"] block:^(PFObject *object, NSError *error) {
            object[@"cancelled"]= @"true";
            [object saveInBackground];
        }];
        NSLog(@"deleted");
        UINavigationController *navController = self.navigationController;
        [navController popViewControllerAnimated:NO];
    } else {
//        UINavigationController *navController = self.navigationController;
//        [navController popViewControllerAnimated:NO];
    }
}

- (IBAction)cancelButton:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Do you wanna cancel your request?" message:@"If you click YES, your request will be removed from the request list." delegate:self cancelButtonTitle:@"NO" otherButtonTitles: nil];
    [alert addButtonWithTitle:@"YES"];
    [alert show];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.phoneNumber = [[NSString alloc] init];
    PFQuery *query = [MyUser query];
    [query whereKey:@"objectId" equalTo: [self.request valueForKeyPath:@"delivererId"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            if ([objects count] > 0){
                self.phoneNumber = ((MyUser *)objects[0]).additional;
                NSLog(@"%@", self.phoneNumber);
                self.phoneNum = TRUE;
            }
        }
    }];

//    self.deliverer.text = [NSString stringWithFormat:@("Deliverer: %@"), [self.request valueForKeyPath:@"deliverer"]];
    
    // Do any additional setup after loading the view.
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

@end
