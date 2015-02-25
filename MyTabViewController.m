//
//  MyTabViewController.m
//  LocationNotifier
//
//  Created by Yongsung on 10/14/14.
//  Copyright (c) 2014 NU. All rights reserved.
//

#import "MyTabViewController.h"
#import "RWDropdownMenu.h"

@interface MyTabViewController ()
@property (nonatomic, strong) NSArray *menuItems;

@property (nonatomic, assign) RWDropdownMenuStyle menuStyle;

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation MyTabViewController

- (NSArray *)menuItems
{
    if (!_menuItems)
    {
        _menuItems =
        @[
          [RWDropdownMenuItem itemWithText:@"Twitter" image:[UIImage imageNamed:@"icon_twitter"] action:nil],
          [RWDropdownMenuItem itemWithText:@"Facebook" image:[UIImage imageNamed:@"icon_facebook"] action:nil],
          [RWDropdownMenuItem itemWithText:@"Message" image:[UIImage imageNamed:@"icon_message"] action:nil],
          [RWDropdownMenuItem itemWithText:@"Email" image:[UIImage imageNamed:@"icon_email"] action:nil],
          [RWDropdownMenuItem itemWithText:@"Save to Photo Album" image:[UIImage imageNamed:@"icon_album"] action:nil],
          ];
    }
    return _menuItems;
}

- (void)presentMenuFromNav:(id)sender
{
    RWDropdownMenuCellAlignment alignment = RWDropdownMenuCellAlignmentCenter;
    if (sender == self.navigationItem.leftBarButtonItem)
    {
        alignment = RWDropdownMenuCellAlignmentLeft;
    }
    else
    {
        alignment = RWDropdownMenuCellAlignmentRight;
    }
    
    [RWDropdownMenu presentFromViewController:self withItems:self.menuItems align:alignment style:self.menuStyle navBarImage:[sender image] completion:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"nav_menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(presentMenuFromNav:)];
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
