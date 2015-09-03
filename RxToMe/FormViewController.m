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
#import "UIView+FindFirstResponder.h"
#import "NSString+PhoneFormating.h"

@interface FormViewController ()

@property (weak, nonatomic) IBOutlet UITextField *name_field;
@property (weak, nonatomic) IBOutlet UITextField *email_field;
@property (weak, nonatomic) IBOutlet UITextField *phone_field;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tap_recognizer;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) User *user;

@end

@implementation FormViewController {
    double topInsert;
}

#pragma mark - View Rendering

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _phone_field.delegate = self;
    _user = [User sharedManager];
    [self setTitle:@"Contact Information"];
    if (_is_modal) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(nextButtonPressed:)];
    }
    [self registerForKeyboardNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    self.name_field.text = _user.name;
    self.email_field.text = _user.email;
    self.phone_field.text = [_user.phone stringToPhone];
}

- (void)viewWillDisappear:(BOOL)animated {
    _user.name = self.name_field.text;
    _user.email = self.email_field.text;
    _user.phone = [self.phone_field.text phoneToString];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard Functions

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification {
    UIView *firstResponder = [self.view findFirstResponder];
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    _scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, firstResponder.frame.origin) ) {
        [self.scrollView scrollRectToVisible:firstResponder.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    _scrollView.contentInset = UIEdgeInsetsZero;
    _scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

#pragma mark - Actions

- (IBAction)nameIconTapped:(id)sender {
    [self.name_field becomeFirstResponder];
}

- (IBAction)emailIconTapped:(id)sender {
    [self.email_field becomeFirstResponder];
}

- (IBAction)phoneIconTapped:(id)sender {
    [self.phone_field becomeFirstResponder];
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

#pragma mark - UITextFieldDelegate Functions
// Navigating through textfields
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        [self nextButtonPressed:nil];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Telephone number field tag
    if (textField.tag == 2) {
        switch (textField.text.length) {
            // adding/rmving opening paren
            case 0:
                if (string.length)
                    textField.text = @"(";
                break;
            // rmving opening paren
            case 2:
                if (!string.length)
                    textField.text = @"";
                break;
            // adding closing paren
            case 4:
                if (string.length)
                    textField.text = [NSString stringWithFormat:@"%@) ", textField.text];
                break;
            // rmving closing paren
            case 7:
                if (!string.length)
                    textField.text = [textField.text substringToIndex:textField.text.length-2];
                break;
            // adding hyphen
            case 9:
                if (string.length)
                    textField.text = [NSString stringWithFormat:@"%@-", textField.text];
                break;
            // rmving hyphen
            case 11:
                if (!string.length)
                    textField.text = [textField.text substringToIndex:textField.text.length-1];
                break;
            default:
                if (textField.text.length >= 14 && string.length)
                    return NO;
                break;
        }
    }
    return YES;
}

#pragma mark - Validation

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

#pragma mark - Navigation

- (void)dismiss {
    NSString *errors = [self validateForm];
    if (errors.length > 0) {
        [self presentErrors:errors];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)presentErrors:(NSString*)errors {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please fix error" message:errors preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
