//
//  CashOrInsuranceViewController.m
//  RxToMe
//
//  Created by Michael Spearman on 8/21/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import "CashOrInsuranceViewController.h"
#import "ConfirmationViewController.h"
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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)cashButtonPressed:(id)sender {
    _user.has_insurance = NO;
    ConfirmationViewController *confirmation = [self.storyboard instantiateViewControllerWithIdentifier:@"Terms"];
    [self.navigationController pushViewController:confirmation animated:YES];
}

- (IBAction)insuranceButtonPressed:(id)sender {
    _user.has_insurance = YES;
    InstructionsViewController *insurnace = [self.storyboard instantiateViewControllerWithIdentifier:@"Instruct"];
    insurnace.type = @"insurance";
    [self.navigationController pushViewController:insurnace animated:YES];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
