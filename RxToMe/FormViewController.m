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
@property (weak, nonatomic) IBOutlet UISwitch *insurance_switch;

@property (weak, nonatomic) User *user;

@end

@implementation FormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tap_recognizer.delegate = self;
    _phone_field.delegate = self;
    _user = [User sharedManager];
    [self setTitle:@"Contact Information"];
}

- (void)viewWillAppear:(BOOL)animated {
    self.name_field.text = _user.name;
    self.email_field.text = _user.email;
    self.phone_field.text = _user.phone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (range.location == 2)
        textField.text = [NSString stringWithFormat:@"(%@) ", textField.text];
    if (range.location > 9) return NO;
    
    return YES;
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

- (IBAction)nextButtonPressed:(id)sender {
    NSString *errors = [self validateForm];
    if (errors.length > 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please fix error" message:errors preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        _user.name = self.name_field.text;
        _user.email = self.email_field.text;
        _user.phone = self.phone_field.text;
        _user.has_insurance = _insurance_switch.on;
        AddressFormViewController *address = [self.storyboard instantiateViewControllerWithIdentifier:@"Address"];
        [self.navigationController pushViewController:address animated:YES];
    }
}


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    [self.view endEditing:YES];
    return YES;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//     Get the new view controller using [segue destinationViewController].
//     Pass the selected object to the new view controller.
    
}


@end
