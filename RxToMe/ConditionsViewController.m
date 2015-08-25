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
@property (weak, nonatomic) IBOutlet UILabel *agreement_label;
@property (weak, nonatomic) User *user;
@end

@implementation ConditionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _user = [User sharedManager];
    [self.agreement_text scrollRangeToVisible:NSMakeRange(0, 0)];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    self.agreement_label.text = [NSString stringWithFormat:@"I, %@, agree to the above terms and conditions.", _user.name];
}

- (IBAction)createAccountButtonPressed:(id)sender {
    if (_agree_switch.on) {
        UIViewController *confirmVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Confirmation"];
        [self.navigationController pushViewController:confirmVC animated:YES];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Terms and Conditions" message:@"You must agree to the terms and conditions before continuing" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
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
