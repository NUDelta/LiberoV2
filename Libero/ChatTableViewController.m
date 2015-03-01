//
//  ChatTableViewController.m
//  Libero
//
//  Created by Shana Azria Dev on 2/17/15.
//  Copyright (c) 2015 YK. All rights reserved.
//

#import "ChatTableViewController.h"
#import "ChatWallViewController.h"
#import "MyUser.h"
#import <Parse/Parse.h>
#import "DelivererViewController.h"
#import "AppDelegate.h"
#import "RWDropdownMenu.h"

@interface ChatTableViewController ()
@property (nonatomic, strong) NSArray *chatUsers;
@property (nonatomic, assign) RWDropdownMenuStyle menuStyle;
@end

@implementation ChatTableViewController

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
    [titleButton setTitle:@"Chat Sessions" forState:UIControlStateNormal];
    [titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
    [titleButton addTarget:self action:@selector(presentStyleMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    [titleButton sizeToFit];
    self.navigationItem.titleView = titleButton;
    
    NSLog([PFUser currentUser].username);
    [self startDownloadChatUsers];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewDidAppear:(BOOL)animated {
    
    [self.tableView reloadData];

}

- (void)startDownloadChatUsers
{
    NSMutableArray *tmpUsers = [[NSMutableArray alloc]init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"delivered != %@ && (deliverer == %@ || username == %@)", @"delivered", [PFUser currentUser].username, [PFUser currentUser].username];
    PFQuery *query = [PFQuery queryWithClassName:@"Message" predicate:predicate];
    
    NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
           // NSLog(@"objects - %@", objects);
            for (PFObject *object in objects) {
                NSString *name;
                if ([(NSString *)object[@"username"] isEqualToString:[PFUser currentUser].username]) {
                    name = (NSString *)object[@"deliverer"];
                } else {
                    
                    name = (NSString *)object[@"username"];
                }
                NSLog(@"%@", object);
                NSLog([PFUser currentUser].username);
                NSLog(name);
                if ([tmpDict objectForKey:name] == nil) {
                    //if user isn't already there
                    NSLog(@"%@", name);
                    [tmpUsers addObject: object];
                    [tmpDict setObject:[NSNumber numberWithBool:YES] forKey:name];
                    
                }
                
                //need to add check to only have users whose package you re delivering/people who have your package
                
                
            }
            
                 self.chatUsers = tmpUsers;
                [self.tableView reloadData];
           
            
            
        }
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

//later this needs to be changed to 2 different types of chat -->packages to be delivered and packages requested chats
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    return [self.chatUsers count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *users = self.chatUsers[indexPath.row];
    NSLog(@"%@", users);
    NSString *name;
    if ([[users valueForKeyPath:@"username"] isEqualToString:[PFUser currentUser].username]) {
        name = [users valueForKeyPath:@"deliverer"];
    } else {
        
        name = [users valueForKeyPath:@"username"];
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatUsersCell" forIndexPath:indexPath];
    //NSLog([NSString stringWithFormat:@"%@", [users valueForKeyPath:@"username"]]);
    cell.textLabel.text = [NSString stringWithFormat:name];
    
    return cell;

}

/*-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *users = self.chatUsers[indexPath.row];
    UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"chatNav"];
    NSLog(@"%@", myNav.viewControllers);
    ChatWallViewController * viewController = [myNav.viewControllers firstObject];
   // viewController.other = [NSString stringWithFormat:@"%@", [users valueForKeyPath:@"username"]];
    myNav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:myNav animated:YES completion:nil];
    
}*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
     NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    NSDictionary *users = self.chatUsers[indexPath.row];
    NSString *name;
    if ([[users valueForKeyPath:@"username"] isEqualToString:[PFUser currentUser].username]) {
        name = [users valueForKeyPath:@"deliverer"];
    } else {
        
        name = [users valueForKeyPath:@"username"];
    }
    if([sender isKindOfClass:[UITableViewCell class]]) {
       
        if([segue.identifier isEqualToString:@"chat1"]) {
            if([segue.destinationViewController isKindOfClass:[ChatWallViewController class]]) {
                ChatWallViewController *cvc = [segue destinationViewController];
                cvc.other = [NSString stringWithFormat:name];
                cvc.detailChat = NO;
                NSLog(@"segueing");
            }
        }
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
