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
#import "CircularLoaderView.h"
#import "NSString+PhoneFormating.h"
#import "CamViewController.h"
#import "ConditionsViewController.h"

NSString* const kSuccess = @"Success";
NSString* const kError = @"Error";

@interface ConfirmationViewController ()

@property (weak, nonatomic) User *user;
@property (weak, nonatomic) IBOutlet UILabel *address_label;
@property (weak, nonatomic) IBOutlet UILabel *name_label;
@property (weak, nonatomic) IBOutlet UILabel *email_label;
@property (weak, nonatomic) IBOutlet UILabel *phone_label;
@property (weak, nonatomic) IBOutlet UIImageView *prescription_image;
@property (nonatomic) UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UILabel *signature_label;
@property (nonatomic) CircularLoaderView *progressIndicatorView;
@property (weak, nonatomic) IBOutlet UIButton *change_address_button;
@property (weak, nonatomic) IBOutlet UIButton *change_contact_button;
@property (nonatomic) CamViewController *cameraVC;

@end

@implementation ConfirmationViewController

#pragma mark - View Rendering

- (void)viewDidLoad {
    [super viewDidLoad];
    _cameraVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Camera"];
    _cameraVC.delegate = self;
    
    _user = [User sharedManager];
    _progressIndicatorView = [[CircularLoaderView alloc] initWithFrame: CGRectZero];
    CGRect frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, 100, 100);
    [_progressIndicatorView setFrame:frame];
    _progressIndicatorView.center = self.view.center;
    _progressIndicatorView.autoresizingMask = YES;
    _signature_label.font = [UIFont fontWithName:@"Arty Signature" size:30];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Confirm" style:UIBarButtonItemStylePlain target:self action:@selector(completeButtonPressed:)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderCreated:) name:@"OrderCreated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderCreated:) name:@"AccountRegistered" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:) name:@"FractionCompleted" object:nil];
}


- (void)viewWillAppear:(BOOL)animated {
    [self reloadLabels];
}

// Adjusts labels for possible changes in text.
- (void)reloadLabels {
    NSString *address2_string = _user.address2.length > 0 ? [NSString stringWithFormat:@"%@, ", [_user.address2 capitalizedString]] : @"";
    self.address_label.text = [NSString stringWithFormat:@"Send to: \n%@, %@%@, %@, %@, %@", [_user.address capitalizedString], address2_string, [_user.city capitalizedString], _user.state, _user.zip, _user.country];
    self.name_label.text = [_user.name capitalizedString];
    self.signature_label.text = [_user.name capitalizedString];
    self.email_label.text = _user.email;
    self.phone_label.text = [_user.phone stringToPhone];
    self.prescription_image.image = _user.prescription_image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Listeners

// Handles completion of upload portion by updating loading view.
- (void)updateProgress:(NSNotification*)note {
    NSProgress* prog = note.userInfo[@"progress"];
    [self.progressIndicatorView updateProgress:(CGFloat)prog.fractionCompleted];
}

// Handler for successfull/failed completion of an order.
- (void)orderCreated:(NSNotification*)note {
    [self.progressIndicatorView removeFromSuperview];
    [self enableButtons:YES];
    if (note.userInfo[@"message"]) {
        [self presentAlertType:kError withMessage: note.userInfo[@"message"]];
    } else {
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Completion"] animated:YES];
        [_user empty];
    }
}

#pragma mark - Helpers

// Disables and/or grays out buttons all buttons on view.
- (void)enableButtons:(BOOL)boolean {
    self.navigationItem.rightBarButtonItem.enabled = boolean;
    self.navigationItem.leftBarButtonItem.enabled = boolean;
    self.change_address_button.enabled = boolean;
    self.change_contact_button.enabled = boolean;
}

// Presents an alert view of success or failure depending on type.
- (void)presentAlertType:(NSString*)type withMessage:(NSString*)alertMessage {
    UIAlertAction *ok_action;
    if ([type isEqualToString:kError]) {
        ok_action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    } else {
        ok_action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            MainPageViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"Home"];
            [self.navigationController pushViewController:home animated:YES];
        }];
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:type message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:ok_action];
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - UIImagePickerDelegate

- (void)cameraVC:(CamViewController *)cameraVC selectedImage:(UIImage *)selectedImage {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [_prescription_image setImage:selectedImage];
        _user.prescription_image = selectedImage;
    }];
}

- (void)cameraVCDidCancel:(CamViewController *)cameraVC {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

- (IBAction)completeButtonPressed:(id)sender {
    [self.view addSubview:_progressIndicatorView];
    [self enableButtons:NO];
//     or register user depending on login status
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

- (IBAction)takePhoto:(id)sender {
    [self.navigationController presentViewController:_cameraVC animated:YES completion:nil];
}

@end
