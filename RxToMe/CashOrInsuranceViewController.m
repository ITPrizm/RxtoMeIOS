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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
