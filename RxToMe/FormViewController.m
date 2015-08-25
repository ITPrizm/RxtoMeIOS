//
//  FormViewController.m
//  RxToMe
//
//  Created by Michael Spearman on 8/10/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import "FormViewController.h"
#import "User.h"
#import "AddressFormViewController.h"

@interface FormViewController ()

@property (weak, nonatomic) IBOutlet UITextField *name_field;
@property (weak, nonatomic) IBOutlet UITextField *email_field;
@property (weak, nonatomic) IBOutlet UITextField *phone_field;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tap_recognizer;
@property (weak, nonatomic) IBOutlet UIButton *next_button;

@property (weak, nonatomic) User *user;

@end

@implementation FormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _phone_field.delegate = self;
    _user = [User sharedManager];
    [self setTitle:@"Contact Information"];
    if (_is_modal) {
        self.next_button.hidden = YES;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.name_field.text = _user.name;
    self.email_field.text = _user.email;
    self.phone_field.text = _user.phone;
}

- (void)viewWillDisappear:(BOOL)animated {
    _user.name = self.name_field.text;
    _user.email = self.email_field.text;
    _user.phone = self.phone_field.text;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString*)validateForm {
    NSString *errors = @"";
    if (![_user validateLength:_name_field.text])
        errors = @"Name cannot be empty.";
    if (![_user validateEmail:_email_field.text])
        errors = [NSString stringWithFormat:@"%@\n Email addresss invalid.", errors];
    if (![_user validatePhone:_phone_field.text])
        errors = [NSString stringWithFormat:@"%@\n Phone number invalid.", errors];
    return errors;
}

- (IBAction)backgroundTapped:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)nextButtonPressed:(id)sender {
    NSString *errors = [self validateForm];
    if (errors.length > 0) {
        [self presentErrors:errors];
    } else {
        AddressFormViewController *address = [self.storyboard instantiateViewControllerWithIdentifier:@"Address"];
        [self.navigationController pushViewController:address animated:YES];
    }
}

- (void)presentErrors:(NSString*)errors {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please fix error" message:errors preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - Navigation

- (void)dismiss {
    NSString *errors = [self validateForm];
    if (errors.length > 0) {
        [self presentErrors:errors];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


@end
