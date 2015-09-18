//
//  CompletionViewController.m
//  RxToMe
//
//  Created by Michael Spearman on 9/11/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import "CompletionViewController.h"
#import "User.h"
#import "CircularLoaderView.h"
#import "MainPageViewController.h"

@interface CompletionViewController ()

@property User *user;
@property CircularLoaderView *progressIndicatorView;

@end

@implementation CompletionViewController

- (void)viewDidLoad {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(nextButtonPressed)];
    self.navigationItem.hidesBackButton = YES;
}

- (void)nextButtonPressed {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Home"] animated:YES];
}

@end
