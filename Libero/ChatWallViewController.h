//
//  ChatWallViewController.h
//  Libero
//
//  Created by Shana Azria Dev on 2/17/15.
//  Copyright (c) 2015 YK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatWallViewController : UIViewController {
     NSString *other;
}
- (IBAction)deliveredPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *deliveredBttn;
@property (weak, nonatomic) IBOutlet UITextField *messageInput;
- (IBAction)sendMessage:(id)sender;
@property NSString *other;
@property BOOL *detailChat;
@property NSString *objId;
@end
