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
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (assign) BOOL saved;
@end

@implementation AddRequestViewController

- (void)presentStyleMenu:(id)sender
{
    NSArray *styleItems =
    @[
      [RWDropdownMenuItem itemWithText:@"My Requests" image:nil action:^{
          UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"requestsNav"];
          myNav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
          [self presentViewController:myNav animated:YES completion:nil];
          self.menuStyle = RWDropdownMenuStyleTranslucent;
      }],
      [RWDropdownMenuItem itemWithText:@"Current Pickups" image:nil action:^{
          UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"currentPickupNav"];
          myNav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
          [self presentViewController:myNav animated:YES completion:nil];
          self.menuStyle = RWDropdownMenuStyleTranslucent;
      }],
      [RWDropdownMenuItem itemWithText:@"Others' Requests" image:nil action:^{
          UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"friendR"];
          myNav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
          [self presentViewController:myNav animated:YES completion:nil];
          self.menuStyle = RWDropdownMenuStyleBlackGradient;
      }],
      [RWDropdownMenuItem itemWithText:@"Profile" image:nil action:^{
          UINavigationController *myNav = [self.storyboard instantiateViewControllerWithIdentifier:@"profileNav"];
          myNav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
          [self presentViewController:myNav animated:YES completion:nil];
          self.menuStyle = RWDropdownMenuStyleTranslucent;
      }],
      ];

    
    [RWDropdownMenu presentFromViewController:self withItems:styleItems align:RWDropdownMenuCellAlignmentCenter style:self.menuStyle navBarImage:nil completion:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    self.spinner.hidden = TRUE;
    [self.spinner stopAnimating];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.descriptionTextField resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [self appUsageLogging:@"add new request"];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.overlayLabel.hidden = TRUE;
    self.spinner.hidden = TRUE;
    self.saved = FALSE;
    self.navigationController.navigationBarHidden=NO;
    self.descriptionTextField.delegate = self;
    [self.descriptionTextField setReturnKeyType:UIReturnKeyDone];
    /*UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [titleButton setImage:[[UIImage imageNamed:@"down@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [titleButton setTitle:@"Add New Request" forState:UIControlStateNormal];
    [titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
    [titleButton addTarget:self action:@selector(presentStyleMenu:) forControlEvents:UIControlEventTouchUpInside];
    [titleButton setTintColor:[UIColor blackColor]];
    [titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [titleButton sizeToFit];
    self.navigationItem.titleView = titleButton;*/
    
    self.packageSize = @"Small";
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
    [navItem.rightBarButtonItem setTintColor:[UIColor blackColor]];
    [navItem.leftBarButtonItem setTintColor:[UIColor blackColor]];
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
    if(!self.saved){
        self.saved = TRUE;
        NSLog(@"save request");
        [self appUsageLogging:@"added new request"];
        PFObject *req = [PFObject objectWithClassName:@"Message"];
        if (self.imageView.image != NULL) {
            NSData* data = UIImageJPEGRepresentation(self.imageView.image, 0.5f);
            PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:data];
            [req setObject:imageFile forKey:@"image"];
        }
        req[@"username"] = [MyUser currentUser].username;
        req[@"email"] = [MyUser currentUser].email;
//        req[@"residenceHall"] = [MyUser currentUser].residenceHall;
        req[@"deliverer"] = @"null";
        req[@"delivererId"] = @"null";
        req[@"delivered"] = @"waiting for pickup";
        req[@"itemDescription"] = self.descriptionTextField.text;
        req[@"packageType"] = self.packageSize;
        self.spinner.hidden = FALSE;
         self.overlayLabel.hidden = FALSE;
        [self.spinner startAnimating];
        [req saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            self.descriptionTextField = @"";
            self.imageView.image = nil;
            [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
        }];
    }

}

- (void)appUsageLogging: (NSString *)activity {
    PFObject *usage = [PFObject objectWithClassName:@"UsageLog"];
    usage[@"username"] = [MyUser currentUser].username;
    usage[@"userid"] = [MyUser currentUser].objectId;
    usage[@"activity"] = activity;
    [usage saveInBackground];
}

- (void)cancelRequest {
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