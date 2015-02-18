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
@interface ChatWallViewController ()

@end

@implementation ChatWallViewController
@synthesize other;

- (void)viewDidLoad {
    [super viewDidLoad];
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
    NSString * tmpNames;
    if ((NSComparisonResult)[[PFUser currentUser].username compare: other] == NSOrderedAscending) {
        tmpNames = [NSString stringWithFormat: @"%@%@", [PFUser currentUser].username, other];
        
    } else {
         tmpNames = [NSString stringWithFormat: @"%@%@", other, [PFUser currentUser].username];
    }
    
    if ([segue.identifier isEqualToString: @"show detail chat"]) {
        ChatDetailTableViewController *vc = [segue destinationViewController];
       // [vc setCombNames:tmpNames];
        ////vc.combNames = tmpNames;
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

@end
