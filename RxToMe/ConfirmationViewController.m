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
#import "AddressFormViewController.h"

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
@property (weak, nonatomic) IBOutlet UILabel *signature_label;

@end

@implementation ConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _image_controller = [[UIImagePickerController alloc] init];
    _image_controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    _image_controller.delegate = self;
    _user = [User sharedManager];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Order" style:UIBarButtonItemStylePlain target:self action:@selector(completeButtonPressed:)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderCreated:) name:@"OrderCreated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderCreated:) name:@"RegistrationComplete" object:nil];
}

- (IBAction)takePhoto:(id)sender {
    [self.navigationController presentViewController:_image_controller animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [_prescription_image setImage:image];
        [_user setPrescription_image:image];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    self.address_label.text = [NSString stringWithFormat:@"Send to: \n%@, %@, %@, %@, %@", [_user.address capitalizedString], [_user.city capitalizedString], _user.state, _user.zip, _user.country];
    self.name_label.text = [_user.name capitalizedString];
    self.signature_label.text = [_user.name capitalizedString];
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
    
    if (!note.userInfo[@"message"]) {
        alertTitle = @"Success";
        alertMessage = @"Your order has been submitted.";
    } else {
        alertTitle = @"Error";
        alertMessage = note.userInfo[@"message"];
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok_action;
    if (!note.userInfo[@"message"]) {
        [_user empty];
        ok_action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            MainPageViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"Home"];
            [self.navigationController pushViewController:home animated:YES];
        }];
    } else {
        ok_action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
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
    // or register user depending on login status
    if (_user.logged_in) {
        [_user createOrder];
    } else {
        [_user registerAccount];
    }
}
- (IBAction)changeAddressButtonPressed:(id)sender {
    AddressFormViewController *addressVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Address"];
    addressVC.is_modal = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:addressVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    
}

- (IBAction)changeContactButtonPressed:(id)sender {
    FormViewController *formVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Form"];
    formVC.is_modal = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:formVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

/*

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
