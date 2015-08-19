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

@property (nonatomic) CLLocationManager *location_manager;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) IBOutlet UISwitch *location_switch;
@property (weak, nonatomic) IBOutlet UITextField *state_field;
@property (weak, nonatomic) IBOutlet UITextField *zip_field;
@property (weak, nonatomic) IBOutlet UITextField *city_field;
@property (weak, nonatomic) IBOutlet UITextField *address_field;
@property (weak, nonatomic) IBOutlet UITextField *country_field;
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
    self.location_manager = [[CLLocationManager alloc] init];
    [self.tap_recognizer setDelegate:self];
    [self.location_manager setDelegate:self];
    [self.picker setDelegate:self];
    [self.picker setDataSource:self];
    [self.state_field setDelegate:self];
    [self.country_field setDelegate:self];
    [self setTitle:@"Contact Information"];
    _picker.hidden = YES;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    self.address_field.text = _user.address;
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
    _user.zip = self.zip_field.text;
    _user.country = _country_field.text;
    _user.state = _state_field.text;
    _user.city = _city_field.text;
}

- (IBAction)switchSwitched:(id)sender {
    if (((UISwitch*)sender).on) {
        [self.location_manager startUpdatingLocation];
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.center = self.view.center;
        [_indicator startAnimating];
        _state_field.enabled = YES;
        _city_field.enabled = YES;
        _zip_field.enabled = YES;
        [self.view addSubview:_indicator];
    }
}

- (IBAction)backgroundTapped:(id)sender {
    [self.picker setHidden:YES];
    [self.next_button setHidden:NO];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    [self.view endEditing:YES];
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
        errors = [NSString stringWithFormat:@"%@\n Zip cannot be empty.", errors];
    return errors;
}

#pragma mark - CoreLocationDelegate Functions

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = locations.lastObject;
    [self.location_manager stopUpdatingLocation];
    [self fillFieldsWith:location];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location Error: %@", error.description);
}

- (void)fillFieldsWith:(CLLocation*)location {
    CLGeocoder *geo = [[CLGeocoder alloc] init];
    [geo reverseGeocodeLocation:location completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         if ([placemarks count] > 0 && error == nil) {
             CLPlacemark *placemark = placemarks[0];
             self.zip_field.text = placemark.postalCode;
             self.city_field.text = placemark.locality;
             self.state_field.text = placemark.administrativeArea;
             self.country_field.text = placemark.country;
             [_indicator stopAnimating];
             [_indicator removeFromSuperview];
         }
     }
     ];
}

#pragma mark - UITextFieldDelegate Functions

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([textField.restorationIdentifier isEqualToString:@"country"]) {
        _picker_data = @[@"Canada", @"USA"];
    } else if ([textField.restorationIdentifier isEqualToString:@"state"]) {
        if ([_country_field.text isEqualToString:@"USA"])
            _picker_data = @[@"Alabama", @"Alaska", @"Arizona", @"Arkansas", @"California", @"Colorado", @"Connecticut", @"Delaware", @"Florida", @"Georgia", @"Hawaii", @"Idaho", @"Illinois", @"Indiana", @"Iowa", @"Kansas", @"Kentucky", @"Louisiana", @"Maine", @"Maryland", @"Massachusetts", @"Michigan", @"Minnesota", @"Mississippi", @"Missouri", @"Montana", @"Nebraska", @"Nevada", @"New Hampshire", @"New Jersey", @"New Mexico", @"New York", @"North Carolina", @"North Dakota", @"Ohio", @"Oklahoma", @"Oregon", @"Pennsylvania", @"Rhode Island", @"South Carolina", @"South Dakota", @"Tennessee", @"Texas", @"Utah", @"Vermont", @"Virginia", @"Washington", @"West Virginia", @"Wisconsin", @"Wyoming"];
        else
            _picker_data = @[@"Alberta", @"British Columbia", @"Ontario", @"Manitoba", @"Nanavut", @"New Brunswick", @"Nova Scotia", @"Prince Edward", @"Newfoundland", @"Northwest Territories", @"Yukon", @"Saskatchewan", @"Quebec"];
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

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _picker.hidden = YES;
    if ([_selected_field.restorationIdentifier isEqualToString:@"country"]) {
        _country_field.text = _picker_data[row];
        _state_field.enabled = YES;
    } else if ([_selected_field.restorationIdentifier isEqualToString:@"state"]) {
        _state_field.text = _picker_data[row];
    }
    _next_button.hidden = NO;
}

#pragma mark - Navigation

- (IBAction)nextButtonPressed:(id)sender {
    NSString *errors = [self validateForm];
    if (errors.length > 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please fix error" message:errors preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        if (_user.has_insurance) {
            InstructionsViewController *insurnace = [self.storyboard instantiateViewControllerWithIdentifier:@"Instruct"];
            insurnace.type = @"insurance";
            [self.navigationController pushViewController:insurnace animated:YES];
        } else {
            ConditionsViewController *conditions = [self.storyboard instantiateViewControllerWithIdentifier:@"Terms"];
            [self.navigationController pushViewController:conditions animated:YES];
        }
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
