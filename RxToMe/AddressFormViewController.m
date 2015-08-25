//
//  AddressFormViewController.m
//  RxToMe
//
//  Created by Michael Spearman on 8/12/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import "AddressFormViewController.h"
#import "User.h"
#import "InstructionsViewController.h"
#import "ConditionsViewController.h"


@interface AddressFormViewController ()
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tap_recognizer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *picker_gesture;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) IBOutlet UITextField *state_field;
@property (weak, nonatomic) IBOutlet UITextField *zip_field;
@property (weak, nonatomic) IBOutlet UITextField *city_field;
@property (weak, nonatomic) IBOutlet UITextField *address_field;
@property (weak, nonatomic) IBOutlet UITextField *address2_field;
@property (weak, nonatomic) IBOutlet UITextField *country_field;
@property (weak, nonatomic) IBOutlet UIImageView *state_icon;
@property (weak, nonatomic) IBOutlet UIImageView *zip_icon;
@property (weak, nonatomic) User *user;
@property NSArray *picker_data;
@property (weak, nonatomic) UITextField *selected_field;
@property (nonatomic) UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIButton *next_button;

@end

@implementation AddressFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _user = [User sharedManager];
    [self.picker_gesture setDelegate:self];
    [self.picker setDelegate:self];
    [self.picker setDataSource:self];
    [self.state_field setDelegate:self];
    [self.country_field setDelegate:self];
    [self setTitle:@"Contact Information"];
    _picker.hidden = YES;
    _picker_gesture.cancelsTouchesInView = NO;
    
    if (_is_modal) {
        self.next_button.hidden = YES;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    }
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    self.address_field.text = _user.address;
    self.address2_field.text = _user.address2;
    self.zip_field.text = _user.zip;
    self.state_field.text = _user.state;
    self.city_field.text = _user.city;
    self.country_field.text = _user.country;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    _user.address = self.address_field.text;
    _user.address2 = self.address2_field.text;
    _user.zip = self.zip_field.text;
    _user.country = _country_field.text;
    _user.state = _state_field.text;
    _user.city = _city_field.text;
}

- (IBAction)backgroundTapped:(id)sender {
    [self.picker setHidden:YES];
    if (!_is_modal)
        _next_button.hidden = NO;
    [self.view endEditing:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (NSString*)validateForm {
    NSString *errors = @"";
    if (![_user validateLength:_address_field.text])
        errors = @"Address cannot be empty.";
    if (![_user validateLength:_country_field.text])
        errors = [NSString stringWithFormat:@"%@\n Country cannot be empty.", errors];
    if (![_user validateLength:_state_field.text])
        errors = [NSString stringWithFormat:@"%@\n State cannot be empty.", errors];
    if (![_user validateLength:_city_field.text])
        errors = [NSString stringWithFormat:@"%@\n City cannot be empty.", errors];
    if (![_user validateLength:_zip_field.text])
        errors = [NSString stringWithFormat:@"%@\n Postal code cannot be empty.", errors];
    else {
        if ([_country_field.text isEqualToString:@"Canada"]) {
            if (![_user validatePostalCode:_zip_field.text])
                errors = [NSString stringWithFormat:@"%@\n Postal code is invalid.", errors];
        } else {
            if (![_user validateZip:_zip_field.text])
                errors = [NSString stringWithFormat:@"%@\n Zip code is invalid.", errors];
        }
    }
    return errors;
}

#pragma mark - UITextFieldDelegate Functions

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([textField.restorationIdentifier isEqualToString:@"country"]) {
        [self.view endEditing:YES];
        _picker_data = @[@"Canada", @"USA"];
    } else if ([textField.restorationIdentifier isEqualToString:@"state"]) {
        if ([_country_field.text isEqualToString:@"USA"])
            _picker_data = @[@"AL", @"AK", @"AZ", @"AR", @"CA", @"CO", @"CT", @"DC", @"DE", @"FL", @"GA",
                             @"HI", @"ID", @"IL", @"IN", @"IA", @"KS", @"KY", @"LA", @"ME", @"MD",
                             @"MA", @"MI", @"MN", @"MS", @"MO", @"MT", @"NE", @"NV", @"NH", @"NJ",
                             @"NM", @"NY", @"NC", @"ND", @"OH", @"OK", @"OR", @"PA", @"RI", @"SC",
                             @"SD", @"TN", @"TX", @"UT", @"VT", @"VA", @"WA", @"WV", @"WI", @"WY"];
        else
            _picker_data = @[@"AB", @"BC", @"MB", @"NB", @"NL", @"NS", @"NT", @"NU", @"ON", @"PE", @"QC", @"SK", @"YT"];
    }
    [_picker reloadAllComponents];
    _selected_field = textField;
    _picker.hidden = NO;
    _next_button.hidden = YES;
    return NO;
}

#pragma mark - UIPickerViewDelegate Functions

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _picker_data.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _picker_data[row];
}

- (IBAction)pickerViewTapGestureRecognized:(id)sender {
    UITapGestureRecognizer *gestureRecognizer = (UITapGestureRecognizer*) sender;
    CGPoint touchPoint = [gestureRecognizer locationInView:gestureRecognizer.view.superview];
    
    CGRect frame = self.picker.frame;
    CGRect selectorFrame = CGRectInset( frame, 0.0, self.picker.bounds.size.height * 0.85 / 2.0 );
    
    if( CGRectContainsPoint( selectorFrame, touchPoint) ) {
        if ([_selected_field.restorationIdentifier isEqualToString:@"country"]) {
            _country_field.text = _picker_data[[self.picker selectedRowInComponent:0]];
            _state_field.text = @"";
            _state_field.enabled = YES;
            if ([_country_field.text isEqualToString:@"Canada"]) {
                _state_icon.image = [UIImage imageNamed:@"textbox_province"];
                _zip_icon.image = [UIImage imageNamed:@"textbox_postal_code"];
                _state_field.placeholder = @"Province";
                _zip_field.placeholder = @"Postal Code";
            } else {
                _state_icon.image = [UIImage imageNamed:@"icon_state"];
                _zip_icon.image = [UIImage imageNamed:@"icon_zip"];
                _state_field.placeholder = @"State";
                _zip_field.placeholder = @"Zip Code";
            }
            
        } else if ([_selected_field.restorationIdentifier isEqualToString:@"state"]) {
            _state_field.text = _picker_data[[self.picker selectedRowInComponent:0]];
        }
        _picker.hidden = YES;
        
        if (!_is_modal)
            _next_button.hidden = NO;
    }
}

- (void)presentErrors:(NSString*)errors {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please fix error" message:errors preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Navigation

- (IBAction)nextButtonPressed:(id)sender {
    NSString *errors = [self validateForm];
    if (errors.length > 0) {
        [self presentErrors:errors];
    } else {
        UIViewController *cashOrInsuranceVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CashOrInsurance"];
        [self.navigationController pushViewController:cashOrInsuranceVC animated:YES];
    }
}

- (void)dismiss {
    NSString *errors = [self validateForm];
    if (errors.length > 0) {
        [self presentErrors:errors];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


/*

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
