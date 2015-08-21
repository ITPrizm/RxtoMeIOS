//
//  MainPageViewController.m
//  RxToMe
//
//  Created by Michael Spearman on 8/10/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import "MainPageViewController.h"
#import "InstructionsViewController.h"
#import "User.h"

@interface MainPageViewController ()
@property (weak, nonatomic) IBOutlet UIButton *get_started_button;
@property (weak, nonatomic) IBOutlet UIButton *login_button;
@property (nonatomic) UIActivityIndicatorView *loading;
@property (nonatomic) UIAlertAction *forgot_alert;
@property (nonatomic) UIAlertAction *login_alert;

@end

@implementation MainPageViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = true;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginComplete:) name:@"LoginComplete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passwordRecoveryComplete:) name:@"PasswordRecoveryComplete" object:nil];
}

- (void)loginComplete:(NSNotification*)note {
    [_loading removeFromSuperview];
    if (!note.userInfo) {
        [self getStartedButtonPressed:self];
    } else {
        [self presentSingleActionAlertWithTitle:@"Error" message:note.userInfo[@"message"]];
    }
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

- (void)presentSingleActionAlertWithTitle:(NSString*)title message:(NSString*)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)presentLoadingView {
    _loading = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loading.center = self.view.center;
    [_loading startAnimating];
    [self.view addSubview:_loading];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@""] && range.location == 0) {
        _forgot_alert.enabled = NO;
        _login_alert.enabled = NO;
    } else {
        _forgot_alert.enabled = YES;
        _login_alert.enabled = YES;
    }
    return YES;
}

- (IBAction)loginButtonPressed:(id)sender {
    User *user = [User sharedManager];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Login" message:@"Please enter login information" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    _forgot_alert = [UIAlertAction actionWithTitle:@"Forgot Password" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        user.email = ((UITextField*)alertController.textFields[0]).text;
        [self presentLoadingView];
        [user forgotPassword];
    }];
    _login_alert = [UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        user.email = ((UITextField*)alertController.textFields[0]).text;
        user.password = ((UITextField*)alertController.textFields[1]).text;
        [self presentLoadingView];
        
        [user login];
    }];
    _forgot_alert.enabled = NO;
    _login_alert.enabled  = NO;
    [alertController addAction:_login_alert];
    [alertController addAction:_forgot_alert];
    [alertController addAction:cancel];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder  = @"Login";
        textField.delegate     = self;
        textField.keyboardType = UIKeyboardTypeEmailAddress;
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Password";
        textField.secureTextEntry = YES;
    }];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)getStartedButtonPressed:(id)sender {
    InstructionsViewController *prescription = [self.storyboard instantiateViewControllerWithIdentifier:@"Instruct"];
    prescription.type = @"prescription";
    [self.navigationController pushViewController:prescription animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = false;
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
