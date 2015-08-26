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
@property (weak, nonatomic) User *user;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation FormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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

- (void)updateViewConstraints {
    [super updateViewConstraints];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
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

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    UIView *firstResponder;
    for (UIView *view in self.view.subviews) {
        if (view.isFirstResponder)
            firstResponder = view;
    }
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, firstResponder.frame.origin) ) {
        [self.scrollView scrollRectToVisible:firstResponder.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
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
