//
//  MySession.m
//  Libero
//
//  Created by Shana Azria Dev on 3/3/15.
//  Copyright (c) 2015 YK. All rights reserved.
//

#import "MySession.h"

@implementation MySession
@synthesize cwvc;

+ (id)sharedManager {
    static MySession *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

@end
