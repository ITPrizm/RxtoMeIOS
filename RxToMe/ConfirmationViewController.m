//
//  ConfirmationViewController.m
//  RxToMe
//
//  Created by Michael Spearman on 8/10/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import "ConfirmationViewController.h"
#import "FormViewController.h"
#import "User.h"
#import "MainPageViewController.h"

@interface ConfirmationViewController ()

@property (weak, nonatomic) User *user;
@property (weak, nonatomic) IBOutlet UILabel *address_label;
@property (weak, nonatomic) IBOutlet UILabel *name_label;
@property (weak, nonatomic) IBOutlet UILabel *email_label;
@property (weak, nonatomic) IBOutlet UILabel *phone_label;
@property (weak, nonatomic) IBOutlet UIImageView *prescription_image;
@property (weak, nonatomic) IBOutlet UIButton *complete_button;
@property (nonatomic) UIImagePickerController *image_controller;
@property (nonatomic) UIActivityIndicatorView *indicator;

@end

@implementation ConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _image_controller = [[UIImagePickerController alloc] init];
    _image_controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    _image_controller.delegate = self;
    _user = [User sharedManager];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed:)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderCreated:) name:@"OrderCreated" object:nil];
}

- (IBAction)takePhoto:(id)sender {
    [self.navigationController presentViewController:_image_controller animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [_prescription_image setImage:image];
    [_user setPrescription_image:image];
}

- (void)viewWillAppear:(BOOL)animated {
    self.address_label.text = [NSString stringWithFormat:@"Send to: \n%@, %@, %@, %@, %@", _user.address, _user.city, _user.state, _user.zip, _user.country];
    self.name_label.text = _user.name;
    self.email_label.text = _user.email;
    NSString *area_code;
    NSString *prefix;
    NSString *suffix;
    if (_user.phone.length > 0) {
        area_code = [_user.phone substringToIndex:3];
        prefix = [_user.phone substringWithRange:NSMakeRange(3, 3)];
        suffix = [_user.phone substringFromIndex:6];
    }
    self.phone_label.text = [NSString stringWithFormat:@"(%@)-%@-%@", area_code, prefix, suffix];
    self.prescription_image.image = _user.prescription_image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)orderCreated:(NSNotification*)note {
    [_indicator removeFromSuperview];
    NSString *alertTitle, *alertMessage;
    
    if (!note.userInfo[@"error"]) {
        alertTitle = @"Success";
        alertMessage = @"Your order has been submitted.";
    } else {
        alertTitle = @"Error";
        alertMessage = ((NSError*)note.userInfo[@"error"]).localizedDescription;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok_action;
    if (note.userInfo[@"success"]) {
        ok_action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            MainPageViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"Home"];
            [self.navigationController pushViewController:home animated:YES];
        }];
    } else {
        ok_action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *retry_action = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self completeButtonPressed:self];
        }];
        [alertController addAction:retry_action];
    }
    
    [alertController addAction:ok_action];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Navigation

- (IBAction)completeButtonPressed:(id)sender {
    _indicator = [[UIActivityIndicatorView alloc]
                  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicator.center = self.view.center;
    [_indicator startAnimating];
    [self.view addSubview:_indicator];
    [_user createOrder];
}

- (IBAction)editButtonPressed:(id)sender {
    FormViewController *form = [self.storyboard instantiateViewControllerWithIdentifier:@"Form"];
    [self.navigationController pushViewController:form animated:YES];
}

/*

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
