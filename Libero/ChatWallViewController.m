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
@interface ChatWallViewController () <UIAlertViewDelegate>

@end
NSString * tmpNames;

@implementation ChatWallViewController
@synthesize other;
@synthesize detailChat;
@synthesize objId;

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    }
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
