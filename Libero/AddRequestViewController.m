//
//  AddRequestViewController.m
//  Libero
//
//  Created by Yongsung on 2/28/15.
//  Copyright (c) 2015 YK. All rights reserved.
//

#import "AddRequestViewController.h"
#import <Parse/Parse.h>
#import "MyUser.h"
#import "RWDropdownMenu.h"


@interface AddRequestViewController () <UIPickerViewDelegate>
{
    NSMutableArray *_sizeData;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *sizePicker;
@property (strong, nonatomic) NSString *packageSize;
@property (nonatomic, assign) RWDropdownMenuStyle menuStyle;

@end

@implementation AddRequestViewController

- (void)presentStyleMenu:(id)sender
{
    NSArray *styleItems =
    @[
      [RWDropdownMenuItem itemWithText:@"Other's Requests" image:nil action:^{
          UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"friendR"];
          myNav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
          [self presentViewController:myNav animated:YES completion:nil];
          self.menuStyle = RWDropdownMenuStyleBlackGradient;
      }],
      [RWDropdownMenuItem itemWithText:@"Current Pickups" image:nil action:^{
          UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"currentPickupNav"];
          myNav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
          [self presentViewController:myNav animated:YES completion:nil];
          self.menuStyle = RWDropdownMenuStyleTranslucent;
      }],
      [RWDropdownMenuItem itemWithText:@"My Requests" image:nil action:^{
          UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"requestsNav"];
          myNav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
          [self presentViewController:myNav animated:YES completion:nil];
          self.menuStyle = RWDropdownMenuStyleTranslucent;
      }],
      [RWDropdownMenuItem itemWithText:@"Chat Sessions" image:nil action:^{
          UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"chatNav"];
          myNav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
          [self presentViewController:myNav animated:YES completion:nil];
          self.menuStyle = RWDropdownMenuStyleTranslucent;
      }],
      [RWDropdownMenuItem itemWithText:@"Profile" image:nil action:^{
          UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"profileNav"];
          myNav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
          [self presentViewController:myNav animated:YES completion:nil];
          self.menuStyle = RWDropdownMenuStyleTranslucent;
      }],
      [RWDropdownMenuItem itemWithText:@"New Request" image:nil action:^{
          UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"addRequestNav"];
          myNav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
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
    [titleButton setImage:[[UIImage imageNamed:@"down@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [titleButton setTitle:@"Add New Request" forState:UIControlStateNormal];
    [titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
    [titleButton addTarget:self action:@selector(presentStyleMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    [titleButton sizeToFit];
    self.navigationItem.titleView = titleButton;
    
    self.packageSize = [[NSString alloc]init];
    self.sizePicker.dataSource = _sizeData;
    self.sizePicker.delegate = self;
    _sizeData = [[NSMutableArray alloc]init];
    _sizeData = @[@"Small",@"Medium",@"Large"];
    // Do any additional setup after loading the view.
    UINavigationItem *navItem = self.navigationItem;
    navItem.title = @"Add New Request";
    UIBarButtonItem *bbiRight = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveRequest)];
    UIBarButtonItem *bbiLeft = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelRequest)];
    navItem.rightBarButtonItem = bbiRight;
    navItem.leftBarButtonItem = bbiLeft;
}

//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    NSLog(@"%@", _sizeData[row]);
//    return _sizeData[row];
//}

- (IBAction)chooseImageButton:(UIButton *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Choose image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a photo",@"Select a photo", nil];
    [actionSheet showInView:self.view];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //take a photo
    if (buttonIndex == 0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:NULL];
    } else if (buttonIndex ==1 ){ //select a photo
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:NULL];
    }
    NSLog(@"clicked %d", buttonIndex);
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Picker View

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return _sizeData.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return _sizeData[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"%@", _sizeData[row]);
    self.packageSize = _sizeData[row];
}

- (void)saveRequest {
    NSLog(@"save request");
    PFObject *req = [PFObject objectWithClassName:@"Message"];
    if (self.imageView.image != NULL) {
        NSData* data = UIImageJPEGRepresentation(self.imageView.image, 0.5f);
        PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:data];
        [req setObject:imageFile forKey:@"image"];
    }
    req[@"username"] = [MyUser currentUser].username;
    req[@"email"] = [MyUser currentUser].email;
    req[@"residenceHall"] = [MyUser currentUser].residenceHall;
    req[@"deliverer"] = @"null";
    req[@"delivererId"] = @"null";
    req[@"delivered"] = @"waiting for pickup";
    req[@"itemDescription"] = self.descriptionTextField.text;
    req[@"packageType"] = self.packageSize;
    
    [req saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.descriptionTextField = @"";
        self.imageView.image = nil;
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }];
}

- (void)cancelRequest {
    NSLog(@"cancel request");
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
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