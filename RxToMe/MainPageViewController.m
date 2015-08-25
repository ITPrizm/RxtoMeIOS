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

@end

@implementation MainPageViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidLoad];
    [self.get_started_button addTarget:self action:@selector(getStartedButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:@"LoginSuccess" object:nil];
    self.navigationController.navigationBarHidden = true;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)loginSuccess {
    [self dismissViewControllerAnimated:YES completion:^{
        [self navigateToInstructions];
    }];
    
}

- (IBAction)getStartedButtonPressed:(id)sender {
    [self navigateToInstructions];
}

- (void)navigateToInstructions {
    InstructionsViewController *prescription = [self.storyboard instantiateViewControllerWithIdentifier:@"Instruct"];
    prescription.type = @"prescription";
    [self.navigationController pushViewController:prescription animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
