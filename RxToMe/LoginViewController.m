//
//  LoginViewController.m
//  RxToMe
//
//  Created by Michael Spearman on 8/21/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import "LoginViewController.h"
#import "User.h"
#import "InstructionsViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIButton *forgot_password_button;
@property (weak, nonatomic) IBOutlet UIButton *login_button;
@property (weak, nonatomic) IBOutlet UITextField *email_field;
@property (weak, nonatomic) IBOutlet UITextField *password_field;
@property (nonatomic) UIActivityIndicatorView *loading;
@property (weak, nonatomic) User *user;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _user = [User sharedManager];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissSelf)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginError:) name:@"LoginFailure" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passwordRecoveryComplete:) name:@"PasswordRecoveryComplete" object:nil];
    UITapGestureRecognizer *tap_recog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped)];
    [self.view addGestureRecognizer:tap_recog];
}

- (void)backgroundTapped {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonPressed:(id)sender {
    _user.email = _email_field.text;
    _user.password = _password_field.text;
    [self presentLoadingView];
    [_user login];
}

- (void)presentLoadingView {
    _loading = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loading.center = self.view.center;
    [_loading startAnimating];
    [self.view addSubview:_loading];
}

- (IBAction)forgotPasswordButtonPressed:(id)sender {
    [self presentLoadingView];
    [_user forgotPasswordForEmail:_email_field.text];
}

- (void)loginError:(NSNotification*)note {
    [_loading removeFromSuperview];
    [self presentSingleActionAlertWithTitle:@"Error" message:note.userInfo[@"message"]];
}

- (void)presentSingleActionAlertWithTitle:(NSString*)title message:(NSString*)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)passwordRecoveryComplete:(NSNotification*)note {
    [_loading removeFromSuperview];
    NSString *title;
    NSString *message;
    if (!note.userInfo) {
        title = @"Recovered";
        message = @"The password has been sent to your email.";
    } else {
        title = @"Error";
        message = note.userInfo[@"message"];
    }
    [self presentSingleActionAlertWithTitle:title message:message];
}

#pragma mark - Navigation

- (void)dismissSelf {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
