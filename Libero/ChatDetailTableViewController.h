//
//  ChatDetailTableViewController.h
//  Libero
//
//  Created by Shana Azria Dev on 2/17/15.
//  Copyright (c) 2015 YK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTSMessagingCell.h"

@interface ChatDetailTableViewController : UITableViewController {
    NSString *combNames;
    NSArray * messages;
}
@property NSString *combNames;
- (void)dataReloaded;
@property (nonatomic) NSArray * messages;
@end
