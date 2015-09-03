//
//  CashOrInsuranceViewController.m
//  RxToMe
//
//  Created by Michael Spearman on 8/21/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import "CashOrInsuranceViewController.h"
#import "ConditionsViewController.h"
#import "InstructionsViewController.h"
#import "User.h"

@interface CashOrInsuranceViewController ()
@property (weak, nonatomic) IBOutlet UIButton *insurance_button;
@property (weak, nonatomic) IBOutlet UIButton *cash_button;
@property (weak, nonatomic) User *user;
@end

@implementation CashOrInsuranceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _user = [User sharedManager];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)cashButtonPressed:(id)sender {
    _user.has_insurance = NO;
    ConditionsViewController *conditions = [self.storyboard instantiateViewControllerWithIdentifier:@"Terms"];
    [self.navigationController pushViewController:conditions animated:YES];
}

- (IBAction)insuranceButtonPressed:(id)sender {
    _user.has_insurance = YES;
    InstructionsViewController *insurnace = [self.storyboard instantiateViewControllerWithIdentifier:@"Instruct"];
    insurnace.type = @"insurance";
    [self.navigationController pushViewController:insurnace animated:YES];
}

@end
