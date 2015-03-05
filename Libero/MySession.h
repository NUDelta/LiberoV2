//
//  MySession.h
//  Libero
//
//  Created by Shana Azria Dev on 3/3/15.
//  Copyright (c) 2015 YK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatWallViewController.h"

@interface MySession : NSObject {
    ChatWallViewController *cwvc;
    
}
@property (nonatomic, strong) ChatWallViewController *cwvc;
+ (id)sharedManager;
@end
