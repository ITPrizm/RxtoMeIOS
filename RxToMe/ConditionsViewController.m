//
//  ConditionsViewController.m
//  RxToMe
//
//  Created by Michael Spearman on 8/11/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import "ConditionsViewController.h"
#import "User.h"

@interface ConditionsViewController ()
@property (weak, nonatomic) IBOutlet UITextView *agreement_text;
@property (weak, nonatomic) IBOutlet UISwitch *agree_switch;
@property (weak, nonatomic) IBOutlet UIButton *create_account_button;
@property (nonatomic) UIActivityIndicatorView *indicator;
@property (weak, nonatomic) User *user;
@end

@implementation ConditionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _user = [User sharedManager];
    [self.agreement_text scrollRangeToVisible:NSMakeRange(0, 0)];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registrationComplete:) name:@"RegistrationComplete" object:nil];
    // Do any additional setup after loading the view.
}

- (IBAction)createAccountButtonPressed:(id)sender {
    if (_agree_switch.on) {
        if (!_user.logged_in) {
            _indicator = [[UIActivityIndicatorView alloc]
                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            _indicator.center = self.view.center;
            [_indicator startAnimating];
            [self.view addSubview:_indicator];
            [_user registerAccount];
        } else {
            [self navigateToConfirmation];
        }
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Terms and Conditions" message:@"You must agree to the terms and conditions before continuing" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)navigateToConfirmation {
    UIViewController *confirmVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Confirmation"];
    [self.navigationController pushViewController:confirmVC animated:YES];
}


- (void)registrationComplete: (NSNotification*)note {
    [_indicator removeFromSuperview];
    if (note.userInfo) {
        NSDictionary *userInfo = note.userInfo;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Account Info" message:userInfo[@"message"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        _user.logged_in = YES;
        [self navigateToConfirmation];
    }
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
