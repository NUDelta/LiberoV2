//
//  SignInViewController.m
//  Libero
//
//  Created by Yongsung on 11/30/14.
//  Copyright (c) 2014 NU. All rights reserved.
//

#import "SignInViewController.h"
#import "AppDelegate.h"
#import "LogInViewController.h"

@interface SignInViewController ()
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;

@end

@implementation SignInViewController
- (IBAction)logInButton:(UIButton *)sender {
    [PFUser logInWithUsernameInBackground:self.username.text password:self.password.text
        block:^(PFUser *user, NSError *error) {
            if (user) {
//                PFInstallation *installation = [PFInstallation currentInstallation];
//                installation[@"user"] = [PFUser currentUser];
//                [installation saveInBackground];
                PFInstallation *installation = [PFInstallation currentInstallation];
                installation[@"user"] = [PFUser currentUser];
                [installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    AppDelegate *appDelegateTemp = [[UIApplication sharedApplication]delegate];
                    CGSize iOSScreenSize = [[UIScreen mainScreen] bounds].size;
                    if (iOSScreenSize.height == 568){ //iphone 5
                        appDelegateTemp.window.rootViewController = [[UIStoryboard storyboardWithName:@"Storyboard5s" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
                    }
                    if (iOSScreenSize.height == 667){ //iphone 6
                        appDelegateTemp.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
                    }
                    
                }];
                // Do stuff after successful login.
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Libero!" message:@"Wrong password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                // The login failed. Check error to see why.
            }
        }];
}
- (IBAction)SignUpButton:(id)sender {
    CGSize iOSScreenSize = [[UIScreen mainScreen] bounds].size;
    UIViewController* logInViewController;
    if (iOSScreenSize.height == 568){ //iphone 5
        logInViewController = [[UIStoryboard storyboardWithName:@"Storyboard5s" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MyLogInViewController"];
    }
    if (iOSScreenSize.height == 667){ //iphone 6
       logInViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MyLogInViewController"];
    }
    
    [self presentViewController:logInViewController animated:NO completion:NULL];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField==self.username)
        [self.password becomeFirstResponder];
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.username.delegate = self;
    self.password.delegate = self;
    [self.username setReturnKeyType:UIReturnKeyNext];
    [self.password setReturnKeyType:UIReturnKeyDone];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    if (![PFUser currentUser]) {
        
    }
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
