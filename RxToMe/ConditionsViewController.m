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
@property (weak, nonatomic) IBOutlet UIView *lower_view;
@property (weak) IBOutlet UILabel *agreement_label;
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
    
    NSMutableAttributedString *signiture = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"I,  %@  agree to the terms and conditions and to adopt the above electronic representation of my signature for medical purposes.", _user.name]];
    [signiture addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:@"Arty Signature" size:30]
                      range:NSMakeRange(4, _user.name.length)];
    _agreement_label.attributedText = signiture;
}

- (IBAction)createAccountButtonPressed:(id)sender {
    
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Confirmation"] animated:YES];
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
