//
//  MyProfileViewController.m
//  Libero
//
//  Created by Yongsung on 2/28/15.
//  Copyright (c) 2015 YK. All rights reserved.
//

#import "MyProfileViewController.h"
#import "MyUser.h"
#import "RWDropdownMenu.h"

@interface MyProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *email;
@property (weak, nonatomic) IBOutlet UILabel *residenceHall;
@property (nonatomic, assign) RWDropdownMenuStyle menuStyle;
@property (weak, nonatomic) IBOutlet UISwitch *notification;
@end

@implementation MyProfileViewController
- (IBAction)notificationSwitch:(id)sender {
    if ([sender isOn]) {
        NSLog(@"Open");
        
        PFQuery *query = [MyUser query];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error) {
                for(PFObject *object in objects){
                    if([(NSString *)object[@"username"] isEqualToString:(NSString *)[MyUser currentUser].username]) {
                        object[@"notification"] = @"On";
                        NSLog(@"saved notification On!");
                        [self appUsageLogging: @"turned on notification"];
                        [object saveInBackground];
                        NSDictionary *notificationInfo = [NSDictionary dictionaryWithObject:@"On" forKey:@"notificationKey"];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationChanged" object:self userInfo:notificationInfo];

                    }
                }
            }
        }];
    } else {
        PFQuery *query = [MyUser query];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error) {
                for(PFObject *object in objects){
                    if([(NSString *)object[@"username"] isEqualToString:(NSString *)[MyUser currentUser].username]) {
                        object[@"notification"] = @"Off";
                        NSLog(@"saved notification Off!");
                        [self appUsageLogging: @"turned off notification"];
                        [object saveInBackground];
                        NSDictionary *notificationInfo = [NSDictionary dictionaryWithObject:@"Off" forKey:@"notificationKey"];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationChanged" object:self userInfo:notificationInfo];
                    }
                }
            }
        }];
    }
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
      [RWDropdownMenuItem itemWithText:@"New Request" image:nil action:^{
          UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"addRequestNav"];
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
      ];
    
    
    [RWDropdownMenu presentFromViewController:self withItems:styleItems align:RWDropdownMenuCellAlignmentCenter style:self.menuStyle navBarImage:nil completion:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self appUsageLogging:@"profile"];
    self.navigationController.navigationBarHidden=NO;
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [titleButton setImage:[[UIImage imageNamed:@"down@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [titleButton setTitle:@"Profile" forState:UIControlStateNormal];
    [titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
    [titleButton addTarget:self action:@selector(presentStyleMenu:) forControlEvents:UIControlEventTouchUpInside];
    [titleButton setTintColor:[UIColor blackColor]];
    [titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [titleButton sizeToFit];
    self.navigationItem.titleView = titleButton;
    
    self.name.text = [NSString stringWithFormat:@"Name: %@", [MyUser currentUser].username];
    self.email.text = [NSString stringWithFormat:@"Email: %@", [MyUser currentUser].email];
    self.residenceHall.text = [NSString stringWithFormat:@"Residence hall: %@", [MyUser currentUser].residenceHall];

        
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [self appUsageLogging:@"profile"];
    PFQuery *query = [MyUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            for(PFObject *object in objects){
                if([(NSString *)object[@"username"] isEqualToString:(NSString *)[MyUser currentUser].username]) {
                    if ([object[@"notification"] isEqualToString: @"On"])
                        [self.notification setOn:YES];
                    else
                        [self.notification setOn:NO];
                }
            }
        }
    }];

//    PFQuery *query = [MyUser query];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if(!error) {
//            for(PFObject *object in objects){
//                if([(NSString *)object[@"username"] isEqualToString:(NSString *)[MyUser currentUser].username]) {
//                    object[@"notification"] = @"On";
//                    NSLog(@"saved notification On!");
//                    [object saveInBackground];
//                }
//            }
//        }
//    }];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
