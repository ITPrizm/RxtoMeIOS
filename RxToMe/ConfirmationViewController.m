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

NSString* const kSuccess = @"Success";
NSString* const kError = @"Error";

@interface ConfirmationViewController ()

@property (weak, nonatomic) User *user;
@property (weak, nonatomic) IBOutlet UILabel *address_label;
@property (weak, nonatomic) IBOutlet UILabel *name_label;
@property (weak, nonatomic) IBOutlet UILabel *email_label;
@property (weak, nonatomic) IBOutlet UILabel *phone_label;
@property (weak, nonatomic) IBOutlet UIImageView *prescription_image;
@property (nonatomic) UIImagePickerController *image_controller;
@property (nonatomic) UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UILabel *signature_label;
@property (nonatomic) CircularLoaderView *progressIndicatorView;

@end

@implementation ConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _image_controller = [[UIImagePickerController alloc] init];
    _image_controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    _image_controller.delegate = self;
    _user = [User sharedManager];
    _progressIndicatorView = [[CircularLoaderView alloc] initWithFrame: CGRectZero];
    CGRect frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, 100, 100);
    [_progressIndicatorView setFrame:frame];
    _progressIndicatorView.center = self.view.center;
    _progressIndicatorView.autoresizingMask = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Order" style:UIBarButtonItemStylePlain target:self action:@selector(completeButtonPressed:)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderCreated:) name:@"OrderCreated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderCreated:) name:@"AccountRegistered" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:) name:@"FractionCompleted" object:nil];
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
    NSString *address2_string = _user.address2.length > 0 ? [NSString stringWithFormat:@"%@, ", [_user.address2 capitalizedString]] : @"";
    self.address_label.text = [NSString stringWithFormat:@"Send to: \n%@, %@%@, %@, %@, %@", [_user.address capitalizedString], address2_string, [_user.city capitalizedString], _user.state, _user.zip, _user.country];
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

- (void)updateProgress:(NSNotification*)note {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSProgress* prog = note.userInfo[@"progress"];
        [self.progressIndicatorView updateProgress:(CGFloat)prog.fractionCompleted];
    });
}

- (void)orderCreated:(NSNotification*)note {
    [self.progressIndicatorView removeFromSuperview];
    if (note.userInfo[@"message"]) {
        [self presentAlertType:kError withMessage: note.userInfo[@"message"]];
    } else {
        NSString *alertMessage;
        if (_user.logged_in) {
            alertMessage = @"A pharmacy in your area will deliver your product within 24 hours";
        } else {
            alertMessage = @"Your account has been created.\nWe have sent your new password to the email address you provided.\nA pharmacy in your area will deliver your product within 24 hours";
        }
        [self presentAlertType:kSuccess withMessage:alertMessage];
        [_user empty];
    }
}

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

#pragma mark - Navigation

- (IBAction)completeButtonPressed:(id)sender {
    [self.view addSubview:_progressIndicatorView];
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
