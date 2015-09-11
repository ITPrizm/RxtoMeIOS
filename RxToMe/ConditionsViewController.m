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
@property (nonatomic) UIActivityIndicatorView *indicator;
@property (weak, nonatomic) User *user;
@end

@implementation ConditionsViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _user = [User sharedManager];
    [self.agreement_text scrollRangeToVisible:NSMakeRange(0, 0)];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Order" style:UIBarButtonItemStylePlain target:self action:@selector(createAccountButtonPressed:)];
}

- (IBAction)createAccountButtonPressed:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Terms and Conditions" message:@"I agree to adopt the above electronic representation of my signature/initials for medical purposes- just the same as a pen-and-paper signature/initial." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* agree = [UIAlertAction actionWithTitle:@"Accept" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Confirmation"] animated:YES];
    }];
    [alertController addAction:agree];
    
    UIAlertAction* disagree = [UIAlertAction actionWithTitle:@"Reject" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:disagree];
    
    [self presentViewController:alertController animated:YES completion:nil];
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
