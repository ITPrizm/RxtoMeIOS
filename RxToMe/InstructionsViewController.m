//
//  InstructionsViewController.m
//  RxToMe
//
//  Created by Michael Spearman on 8/12/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import "InstructionsViewController.h"
#import "PhotoViewController.h"

@interface InstructionsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *instructions_image;

@end

@implementation InstructionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([_type isEqualToString:@"prescription"]) {
        _instructions_image.image = [UIImage imageNamed:@"prescription_instructions"];
    } else {
        _instructions_image.image = [UIImage imageNamed:@"insurance_instructions"];
    }
    // Do any additional setup after loading the view.
}
- (IBAction)nextButtonPressed:(id)sender {
    PhotoViewController *nextVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Photo"];
    nextVC.type = _type;
    [self.navigationController pushViewController:nextVC animated:YES];
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
