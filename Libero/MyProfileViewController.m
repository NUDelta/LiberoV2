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
@property (weak, nonatomic) IBOutlet UILabel *points;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;
@property (nonatomic, assign) RWDropdownMenuStyle menuStyle;
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
                        [object saveInBackground];
                    }
                }
            }
        }];
    } else {
        NSLog(@"Off");
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
    self.navigationController.navigationBarHidden=NO;
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [titleButton setImage:[[UIImage imageNamed:@"down@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [titleButton setTitle:@"Profile" forState:UIControlStateNormal];
    [titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
    [titleButton addTarget:self action:@selector(presentStyleMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    [titleButton sizeToFit];
    self.navigationItem.titleView = titleButton;
    
    self.name.text = [NSString stringWithFormat:@"Name: %@", [MyUser currentUser].username];
    self.email.text = [NSString stringWithFormat:@"Email: %@", [MyUser currentUser].email];
    self.residenceHall.text = [NSString stringWithFormat:@"Residence hall: %@", [MyUser currentUser].residenceHall];
    self.phoneNumber.text = [NSString stringWithFormat:@"Phone: %@", [MyUser currentUser].additional];
    PFQuery *query = [MyUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            for(PFObject *object in objects){
                if([(NSString *)object[@"username"] isEqualToString:(NSString *)[MyUser currentUser].username]) {
                    self.points.text = [NSString stringWithFormat:@"Points: %@", [object[@"points"] stringValue]];
                    object[@"notification"] = @"On";
                    NSLog(@"saved notification On!");
                    [object saveInBackground];
                }
            }
        }
    }];
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
