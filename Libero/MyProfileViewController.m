//
//  MyProfileViewController.m
//  Libero
//
//  Created by Yongsung on 2/28/15.
//  Copyright (c) 2015 YK. All rights reserved.
//

#import "MyProfileViewController.h"
#import "MyUser.h"

@interface MyProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *email;
@property (weak, nonatomic) IBOutlet UILabel *residenceHall;
@property (weak, nonatomic) IBOutlet UILabel *points;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;

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

- (void)viewDidLoad {
    [super viewDidLoad];
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
