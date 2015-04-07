//
//  MyUser.h
//  LocationNotifier
//
//  Created by Yongsung on 10/13/14.
//  Copyright (c) 2014 NU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface MyUser : PFUser<PFSubclassing>
//@property (retain) NSString *residenceHall;
@property (retain) NSString *additional;
@property (retain) NSString *notification;

@end
