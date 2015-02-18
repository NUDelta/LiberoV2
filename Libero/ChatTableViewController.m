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

@interface ChatTableViewController ()
@property (nonatomic, strong) NSArray *chatUsers;
@end

@implementation ChatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            for (PFObject *object in objects) {
                if ([tmpDict objectForKey:(NSString *)object[@"username"]] == nil) {
                    //if user isn't already there
                    //NSLog((NSString *)object[@"username"]);
                    [tmpUsers addObject: object];
                    [tmpDict setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)object[@"username"]];
                    
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatUsersCell" forIndexPath:indexPath];
    NSLog([NSString stringWithFormat:@"%@", [users valueForKeyPath:@"username"]]);
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [users valueForKeyPath:@"username"]];
    
    return cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *users = self.chatUsers[indexPath.row];
    UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"chatNav"];
    NSLog(@"%@", myNav.viewControllers);
    ChatWallViewController * viewController = [myNav.viewControllers firstObject];
   // viewController.other = [NSString stringWithFormat:@"%@", [users valueForKeyPath:@"username"]];
    myNav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:myNav animated:YES completion:nil];
    
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
