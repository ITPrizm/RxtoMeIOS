//
//  PhotoViewController.m
//  RxToMe
//
//  Created by Michael Spearman on 8/11/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import "PhotoViewController.h"
#import "User.h"
#import "InstructionsViewController.h"

@interface PhotoViewController ()

@property (weak, nonatomic) User *user;
@property (nonatomic) UIImagePickerController *image_controller;
@property (nonatomic) UIButton *prescription_button;
@property (nonatomic) UIButton *insurance_front_button;
@property (nonatomic) UIButton *insurance_back_button;
@property (weak, nonatomic) IBOutlet UILabel *note_label;
@property (weak, nonatomic) IBOutlet UIButton *next_button;
@property (weak, nonatomic) UIButton *selected_apv;

@end

@implementation PhotoViewController

#pragma mark - Loading the View

- (void)viewDidLoad {
    [super viewDidLoad];
    // Used for the prescription and insurance scene
    // Which is loaded depends on _type
    _user = [User sharedManager];
    _image_controller = [[UIImagePickerController alloc] init];
    _image_controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    _image_controller.delegate = self;
    if ([_type isEqualToString:@"prescription"]) {
        [self prescriptionSetup];
    } else {
        [self insuranceSetup];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([_type isEqualToString:@"prescription"]) {
        if (_user.prescription_image) {
            [_prescription_button setImage:_user.prescription_image forState:UIControlStateNormal];
            _note_label.hidden = NO;
        }
    } else {
        _note_label.hidden = YES;
        if (_user.insurance_front) {
            [_insurance_front_button setImage:_user.insurance_front forState:UIControlStateNormal];
        }
        if (_user.insurance_back) {
            [_insurance_back_button setImage:_user.insurance_back forState:UIControlStateNormal];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Setup

- (void)prescriptionSetup {
    _prescription_button = [self setButton:@"Add Prescription" xpos:0 ypos:-50];
}

- (void)insuranceSetup {
    _insurance_back_button = [self setButton:@"Add Insurance Back" xpos:0 ypos:-100];
    _insurance_front_button = [self setButton:@"Add Insurance Front" xpos:0 ypos:100];
    
    [_insurance_front_button setRestorationIdentifier:@"front"];
    [_insurance_back_button setRestorationIdentifier:@"back"];
}

// quasi button factory
- (UIButton*)setButton:(NSString*)title xpos:(NSInteger)xpos ypos:(NSInteger)ypos {
    UIButton *new_button = [[UIButton alloc] init];
    new_button.translatesAutoresizingMaskIntoConstraints = NO;
    new_button.imageView.clipsToBounds = YES;
    new_button.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [new_button setTitle:title forState:UIControlStateNormal];
    [new_button setBackgroundColor:[UIColor grayColor]];
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
                                                            constant:150]
     ];
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:new_button
                                                           attribute:NSLayoutAttributeWidth
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
    [self.navigationController presentViewController:_image_controller animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [_selected_apv setImage:image forState:UIControlStateNormal];
        if ([_type isEqualToString:@"prescription"]) {
            _user.prescription_image = image;
            _note_label.hidden = NO;
        } else {
            if ([_selected_apv.restorationIdentifier isEqualToString: @"front"]) {
                _user.insurance_front = image;
            } else {
                _user.insurance_back = image;
            }
        }
    }];
}

- (void)presentErrorWithMessage:(NSString*)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Missing Photo" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Navigation

- (IBAction)nextButtonPressed:(id)sender {
    UIViewController *conditions = [self.storyboard instantiateViewControllerWithIdentifier:@"Terms"];
    if ([_type isEqualToString:@"prescription"]) {
        if (_prescription_button.imageView.image) {
            if (_user.logged_in) {
                if (_user.has_insurance) {
                    InstructionsViewController *insurnaceVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Instruct"];
                    insurnaceVC.type = @"insurance";
                    [self.navigationController pushViewController:insurnaceVC animated:YES];
                } else {
                    [self.navigationController pushViewController:conditions animated:YES];
                }
            } else {
                UIViewController *formVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Form"];
                [self.navigationController pushViewController:formVC animated:YES];
            }
        } else {
            [self presentErrorWithMessage:@"Add an image of your prescription before continuing."];
        }
    } else {
        if (_insurance_back_button.imageView.image && _insurance_front_button.imageView.image) {
            [self.navigationController pushViewController:conditions animated:YES];
        } else {
            [self presentErrorWithMessage:@"Add images of the front and back of your insurance before continuing."];
        }
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
