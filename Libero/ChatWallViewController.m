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
@interface ChatWallViewController ()

@end
NSString * tmpNames;
@implementation ChatWallViewController
@synthesize other;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", self.childViewControllers);
    NSLog(@"sender - %@ / receiver - %@", [PFUser currentUser].username, other);
    // Do any additional setup after loading the view.
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
@end
