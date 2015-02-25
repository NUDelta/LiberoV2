//
//  ChatDetailTableViewController.m
//  Libero
//
//  Created by Shana Azria Dev on 2/17/15.
//  Copyright (c) 2015 YK. All rights reserved.
//

#import "ChatDetailTableViewController.h"
#import "MyUser.h"
#import "PTSMessagingCell.h"
#import <Parse/Parse.h>

@interface ChatDetailTableViewController ()
@property (nonatomic, strong) NSMutableArray *convo;
@end

@implementation ChatDetailTableViewController
@synthesize combNames;


-(void)dataReloaded {
    NSLog(@"data id getting reloaded");
}


-(void)awakeFromNib {
    
    _messages = [[NSArray alloc] initWithObjects:
                 @"Hello, how are you.",
                 @"I'm great, how are you?",
                                  nil];
    
    [super awakeFromNib];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCombNames:@"adminjiajun l"];
    [self downloadConversation];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) downloadConversation {
    self.convo = [[NSMutableArray alloc]init];
    //use chat
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    NSLog(self.combNames);
   // [query whereKey:@"combinedNames" equalTo:@"self.combNames"];
    //[query whereKey:@"combinedNames" hasPrefix:self.combNames];
   
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            for (PFObject *object in objects) {
                if ([(NSString *)object[@"combinedNames"] isEqualToString:self.combNames]) {
                    [self.convo addObject: object];
                    NSLog(@"%@",object[@"combinedNames"]);
                }
                
                
            }
            
        }

    }];
    NSLog(@"%@", self.convo);

    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"messagingCell";

    PTSMessagingCell * cell = (PTSMessagingCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[PTSMessagingCell alloc] initMessagingCellWithReuseIdentifier:cellIdentifier];
    }
    
   // [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize messageSize = [PTSMessagingCell messageSize:[_messages objectAtIndex:indexPath.row]];
    return messageSize.height + 2*[PTSMessagingCell textMarginVertical] + 40.0f;
}

-(void)configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
    PTSMessagingCell* ccell = (PTSMessagingCell*)cell;
    
    if (indexPath.row % 2 == 0) {
        ccell.sent = YES;
        //ccell.avatarImageView.image = [UIImage imageNamed:@"person1"];
    } else {
        ccell.sent = NO;
        //ccell.avatarImageView.image = [UIImage imageNamed:@"person2"];
    }
    
    ccell.messageLabel.text = [_messages objectAtIndex:indexPath.row];
    
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
