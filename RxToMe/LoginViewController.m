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
#import "CircularLoaderView.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIButton *forgot_password_button;
@property (weak, nonatomic) IBOutlet UIButton *login_button;
@property (weak, nonatomic) IBOutlet UITextField *email_field;
@property (weak, nonatomic) IBOutlet UITextField *password_field;
@property (weak, nonatomic) User *user;
@property (nonatomic) CircularLoaderView *progressIndicatorView;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _user = [User sharedManager];
    _progressIndicatorView = [[CircularLoaderView alloc] initWithFrame: CGRectZero];
    CGRect frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, 100, 100);
    [_progressIndicatorView setFrame:frame];
    _progressIndicatorView.center = self.view.center;
    _progressIndicatorView.autoresizingMask = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissSelf)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginError:) name:@"LoginFailure" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passwordRecoveryComplete:) name:@"PasswordRecoveryComplete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:) name:@"FractionCompleted" object:nil];
    UITapGestureRecognizer *tap_recog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped)];
    [self.view addGestureRecognizer:tap_recog];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notification Handlers

- (void)updateProgress:(NSNotification*)note {
    NSProgress *prog = note.userInfo[@"progress"];
    [_progressIndicatorView updateProgress:prog.fractionCompleted];
}

- (void)loginError:(NSNotification*)note {
    [self finishedLoading];
    [self presentSingleActionAlertWithTitle:@"Error" message:note.userInfo[@"message"]];
}


- (void)passwordRecoveryComplete:(NSNotification*)note {
    NSString *title;
    NSString *message;
    if (!note.userInfo) {
        title = @"Recovered";
        message = @"The password has been sent to your email.";
    } else {
        title = @"Error";
        message = note.userInfo[@"message"];
    }
    [self finishedLoading];
    [self presentSingleActionAlertWithTitle:title message:message];
}

#pragma mark - Helpers

- (void)finishedLoading {
    [self.progressIndicatorView removeFromSuperview];
    [self enableButtons:YES];
}

- (void)enableButtons:(BOOL)enable {
    self.navigationItem.rightBarButtonItem.enabled = enable;
    self.login_button.enabled = enable;
}

- (void)presentSingleActionAlertWithTitle:(NSString*)title message:(NSString*)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Gesture Recognizer Handlers

- (void)backgroundTapped {
    [self.view endEditing:YES];
}

- (IBAction)passwordIconTapped:(id)sender {
    [self.password_field becomeFirstResponder];
}

- (IBAction)emailIconTapped:(id)sender {
    [self.email_field becomeFirstResponder];
}

- (IBAction)loginButtonPressed:(id)sender {
    [self.view addSubview:_progressIndicatorView];
    [self enableButtons:NO];
    [_user loginWithEmail:_email_field.text password:_password_field.text];
}

- (IBAction)forgotPasswordButtonPressed:(id)sender {
    [self.view addSubview:_progressIndicatorView];
    [self enableButtons:NO];
    [_user forgotPasswordForEmail:_email_field.text];
}

#pragma mark - UITextFieldDelegate Functions
// Navigating through textfields
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        [self loginButtonPressed:nil];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

#pragma mark - Navigation

- (void)dismissSelf {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
