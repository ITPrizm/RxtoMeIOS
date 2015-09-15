//
//  PhotoViewController.m
//  RxToMe
//
//  Created by Michael Spearman on 8/11/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import "PhotoViewController.h"
#import "User.h"
#import "CashOrInsuranceViewController.h"
#import "CamViewController.h"

@interface PhotoViewController ()

@property (weak, nonatomic) User *user;
@property (nonatomic) UIButton *prescription_button;
@property (nonatomic) UIButton *insurance_front_button;
@property (nonatomic) UIButton *insurance_back_button;
@property (nonatomic) IBOutlet UILabel *note_label;
@property (weak, nonatomic) UIButton *selected_apv;
@property (nonatomic) CamViewController *cameraVC;

@end

@implementation PhotoViewController

#pragma mark - Loading the View

- (void)viewDidLoad {
    [super viewDidLoad];
    // Used for the prescription and insurance scenes
    // Which is loaded depends on _type
    _user = [User sharedManager];
    
    _cameraVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Camera"];
    _cameraVC.delegate = self;
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
    if ([_type isEqualToString:@"prescription"]) {
        [self prescriptionSetup];
    } else {
        [self insuranceSetup];
    }
}

- (void)backButtonPressed {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Going back to the dashboard will clear your current information, are you sure you want to proceed?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [_user empty];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    UIAlertAction* no = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:yes];
    [alertController addAction:no];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([_type isEqualToString:@"prescription"]) {
        if (_user.prescription_image) {
            [_prescription_button setImage:_user.prescription_image forState:UIControlStateNormal];
            [_prescription_button setBackgroundImage:nil forState:UIControlStateNormal];
            _note_label.hidden = NO;
        }
    } else {
        _note_label.hidden = YES;
        if (_user.insurance_front) {
            [_insurance_front_button setImage:_user.insurance_front forState:UIControlStateNormal];
            [_insurance_front_button setBackgroundImage:nil forState:UIControlStateNormal];
        }
        if (_user.insurance_back) {
            [_insurance_back_button setImage:_user.insurance_back forState:UIControlStateNormal];
            [_insurance_back_button setBackgroundImage:nil forState:UIControlStateNormal];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Setup

- (void)prescriptionSetup {
    _prescription_button = [self setButtonWithXpos:0 ypos:50];
    [_prescription_button setBackgroundImage:[UIImage imageNamed:@"Add Prescription"] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
    self.cameraVC.alwaysLandscape = NO;
}

- (void)insuranceSetup {
    _insurance_front_button = [self setButtonWithXpos:0 ypos:100];
    _insurance_back_button = [self setButtonWithXpos:0 ypos:-150];
    
    [_insurance_front_button setBackgroundImage:[UIImage imageNamed:@"Add Insurance Front"] forState:UIControlStateNormal];
    [_insurance_back_button setBackgroundImage:[UIImage imageNamed:@"Add Insurance Back"] forState:UIControlStateNormal];
    
    [_insurance_front_button setRestorationIdentifier:@"front"];
    [_insurance_back_button setRestorationIdentifier:@"back"];
    self.cameraVC.alwaysLandscape = YES;
}

// Button constructor
- (UIButton*)setButtonWithXpos:(NSInteger)xpos ypos:(NSInteger)ypos {
    UIButton *new_button = [[UIButton alloc] init];
    new_button.translatesAutoresizingMaskIntoConstraints = NO;
    new_button.imageView.clipsToBounds = YES;
    new_button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [new_button addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:new_button];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:0
                                                             toItem:new_button
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:xpos]
     ];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:0
                                                             toItem:new_button
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1
                                                           constant:ypos]
     ];
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:new_button
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1
                                                            constant:200]
     ];

    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:new_button
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:new_button
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:3.0/4.0 //Aspect ratio: 3*height = 4*width
                                                            constant:0.0f]
     ];
    return new_button;
}

- (IBAction)takePhoto:(id)sender {
    _selected_apv = sender;
    [self.navigationController presentViewController:_cameraVC animated:YES completion:nil];
}

- (void)cameraVC:(CamViewController *)cameraVC selectedImage:(UIImage *)selectedImage {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [_selected_apv setImage:selectedImage forState:UIControlStateNormal];
        [_selected_apv setBackgroundImage:nil forState:UIControlStateNormal];
        if ([_type isEqualToString:@"prescription"]) {
            _user.prescription_image = selectedImage;
            _note_label.hidden = NO;
        } else {
            if ([_selected_apv.restorationIdentifier isEqualToString: @"front"]) {
                _user.insurance_front = selectedImage;
            } else {
                _user.insurance_back = selectedImage;
            }
        }
    }];
}

- (void)cameraVCDidCancel:(CamViewController *)cameraVC {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)presentErrorWithMessage:(NSString*)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Missing Photo" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Navigation

- (IBAction)dimisss:(id)sender {
    if ([_type isEqualToString:@"prescription"]) {
        if (_prescription_button.imageView.image) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self presentErrorWithMessage:@"Add an image of your prescription before continuing."];
        }
    } else {
        if (_insurance_back_button.imageView.image && _insurance_front_button.imageView.image) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self presentErrorWithMessage:@"Add images of the front and back of your insurance before continuing."];
        }
    }
}


@end
