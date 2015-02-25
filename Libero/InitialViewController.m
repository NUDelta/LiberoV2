//
//  InitialViewController.m
//  Libero
//
//  Created by Shana Azria Dev on 2/25/15.
//  Copyright (c) 2015 YK. All rights reserved.
//

#import "InitialViewController.h"
#import "RWDropdownMenu.h"


@interface InitialViewController ()
@property (nonatomic, assign) RWDropdownMenuStyle menuStyle;

@end

@implementation InitialViewController



- (void)presentStyleMenu:(id)sender
{
    NSArray *styleItems =
    @[
      [RWDropdownMenuItem itemWithText:@"Black Gradient" image:nil action:^{
          self.menuStyle = RWDropdownMenuStyleBlackGradient;
      }],
      [RWDropdownMenuItem itemWithText:@"Translucent" image:nil action:^{
          UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"friendR"];
          myNav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
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
    [titleButton setImage:[[UIImage imageNamed:@"nav_down"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [titleButton setTitle:@"Menu Style" forState:UIControlStateNormal];
    [titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
    [titleButton addTarget:self action:@selector(presentStyleMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    [titleButton sizeToFit];
    self.navigationItem.titleView = titleButton;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
