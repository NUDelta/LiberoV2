//
//  ViewController.m
//  PTSMessagingCellDemo
//
//  Created by Ralph Gasser on 15.09.12.
//  Copyright (c) 2012 pontius software GmbH. All rights reserved.
//

#import "ViewController.h"
#import "MyUser.h"
#import <Parse/Parse.h>

@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *convo;
@end

@implementation ViewController
@synthesize combNames;

/*-(void)awakeFromNib {
    
    _messages = [[NSMutableArray alloc] initWithObjects:
              @"Hello, how are you.",
              @"I'm great, how are you?",
              @"I'm fine, thanks. Up for dinner tonight?",
              @"Glad to hear. No sorry, I have to work.",
              @"Oh that sucks. A pitty, well then - have a nice day.."
              @"Thanks! You too. Cuu soon.",
                 @"Thanks! You too. Cuu soon.",
                  @"Thanks! You too. Cuu soon.",
                  @"Thanks! You too. Cuu soon.",
                  @"Thanks! You too. Cuu soon.",
                  @"Thanks! You too. Cuu soon.",
                  @"Thanks! You too. Cuu soon.",
                  @"Thanks! You too. Cuu soon.",
                  @"Thanks! You too. Cuu soon.",
                  @"Thanks! You too. Cuu soon.",
                  @"Thanks! You too. Cuu soon.",
                  @"Thanks! You too. Cuu soon.",
                  @"last message.",
              nil];
    
    [super awakeFromNib];
}*/

-(void)dataReloaded {
    NSLog(@"data id getting reloaded");
    NSMutableArray *new = [[NSMutableArray alloc] init];
    NSUInteger c = _messages.count;
    _messages = new;
    sleep(1);
    [self downloadConversation];
    
     [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(dataReloaded) userInfo:nil repeats:YES];
   // NSLog(@"%@", [self parentViewController]);
    _messages = [[NSMutableArray alloc] init];
   // [self setCombNames:@"adminjiajun l"];
    [self downloadConversation];
    
        // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void) downloadConversation {
    self.convo = [[NSMutableArray alloc]init];
    //use chat
    PFQuery *query = [PFQuery queryWithClassName:@"ChatMessages"];
      
    [query whereKey:@"combinedNames" hasPrefix:self.combNames];
    [query orderByAscending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
           //  NSLog(@"%@", objects);
            for (PFObject *object in objects) {
                    [self.convo addObject: object];
                    [self.messages addObject:[NSString stringWithFormat:(NSString *)object[@"message"]]];
                    NSLog(@"%@",self.messages);
                    [self.tableView reloadData];
                
                
                
            }
            
        }
        
    }];
   // NSLog(@"%@", self.messages);
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%lu",(unsigned long)_messages.count);
    return [_messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*This method sets up the table-view.*/
    PFObject *object = [_convo objectAtIndex:([_messages count] - 1 - indexPath.row)];
    static NSString* cellIdentifier = @"messagingCell";
    NSString *userName = [PFUser currentUser].username;
    PTSMessagingCell * cell = (PTSMessagingCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[PTSMessagingCell alloc] initMessagingCellWithReuseIdentifier:cellIdentifier];
    }
   // NSLog(userName);
    if ([(NSString *)object[@"sender"] isEqualToString:userName]) {
        cell.sent = YES;
    } else {
        cell.sent = NO;
    }
    cell.timeLabel.text = (NSString *)object[@"sender"];
    cell.messageLabel.text = [_messages objectAtIndex:([_messages count] - 1 - indexPath.row)];
    //[self configureCell:cell atIndexPath:indexPath];
    
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
    ccell.timeLabel.text = @"2012-08-29";
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}



@end
