//
//  ViewController.h
//  PTSMessagingCellDemo
//
//  Created by Ralph Gasser on 15.09.12.
//  Copyright (c) 2012 pontius software GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTSMessagingCell.h"

@interface ViewController : UIViewController {
    UITableView * tableView;
     NSString *combNames;
    NSMutableArray * messages;
}

@property (nonatomic) IBOutlet UITableView * tableView;
@property NSString *combNames;
@property (nonatomic) NSMutableArray * messages;

@end
