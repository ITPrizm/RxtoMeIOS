//
//  UserModel.m
//  RxToMe
//
//  Created by Michael Spearman on 8/10/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import "User.h"
#import "RxClient.h"

@implementation User

#pragma mark - Singleton Init

+ (id)sharedManager {
    static User *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)init {
    if (self = [super init])
        _device_id = [UIDevice currentDevice].identifierForVendor.UUIDString;
    return self;
}

#pragma mark - POST Requests

- (void)login {
/*  DEVELOPMENT USE ONLY
    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[@"mikespearman.e@gmail.com", @"bHUWy"]
                                                       forKeys:@[@"pt_email", @"pt_upass"]];
*/
    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[_email, _password] forKeys:@[@"pt_email", @"pt_upass"]];
    
    [[RxClient sharedClient] POST:@"http://api.rxtome.com/api/v1/patient/login" parameters:params
                          success:^(NSURLSessionDataTask *task, id responseObject) {
                              NSLog(@"SUCCESS: %@", task.response);
                              _logged_in = YES;
                              NSDictionary *response = (NSDictionary*)responseObject;
                              // Pass response to user fields
                              [self parseLoginResponse:response[@"data"]];
                              [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginComplete" object:nil userInfo:nil];
                          }
                          failure:^(NSURLSessionDataTask *task, NSError *error) {
                              NSLog(@"FAILURE: %@", task.response);
                              NSDictionary* error_info;
                              NSData* response_data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
                              if (response_data) {
                                  error_info = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:response_data options:NSJSONReadingMutableContainers error:nil];
                              } else {
                                  error_info = @{@"message" : error.localizedDescription};
                              }
                              
                              [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginComplete"object:nil userInfo:error_info];
                          }
     ];
}

- (void)createOrder {
    [[RxClient sharedClient] POST:kRxNewOrderEndpoint parameters:[self formatUserParams] constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:UIImageJPEGRepresentation(_prescription_image, .5) name:@"pre_front" fileName:@"pre_front.jpeg" mimeType:@"image/jpeg"];
            if (_has_insurance) {
                [formData appendPartWithFileData:UIImageJPEGRepresentation(_insurance_front, .5) name:@"ins_front" fileName:@"ins_front.jpg" mimeType:@"image/jpeg"];
                [formData appendPartWithFileData:UIImageJPEGRepresentation(_insurance_back, .5) name:@"ins_back" fileName:@"ins_back.jpg" mimeType:@"image/jpeg"];
            }
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"SUCCESS: %@", task.response);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OrderCreated" object:self userInfo:nil];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"FAILURE: %@", task.response);
        NSDictionary* error_info;
        NSData* response_data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
        if (response_data) {
            error_info = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:response_data options:NSJSONReadingMutableContainers error:nil];
        } else {
            error_info = @{@"message" : error.localizedDescription};
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OrderCreated" object:self userInfo:error_info];
    }];
}

- (void)registerAccount {
    [[RxClient sharedClient] POST:kRxNewUserEndpoint parameters:[self formatUserParams] constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:UIImageJPEGRepresentation(_prescription_image, .5) name:@"pre_front" fileName:@"pre_front.jpeg" mimeType:@"image/jpeg"];
            if (_has_insurance) {
                [formData appendPartWithFileData:UIImageJPEGRepresentation(_insurance_front, .5) name:@"ins_front" fileName:@"ins_front.jpg" mimeType:@"image/jpeg"];
                [formData appendPartWithFileData:UIImageJPEGRepresentation(_insurance_back, .5) name:@"ins_back" fileName:@"ins_back.jpg" mimeType:@"image/jpeg"];
            }
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"SUCCESS: %@", task.response);
        NSDictionary *response = (NSDictionary*)responseObject;
        _logged_in = YES;
        // Pass response to user fields
        [self parseRegistrationResponse:response[@"data"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RegistrationComplete" object:self userInfo:nil];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"FAILURE: %@", task.response);
        
        NSDictionary* error_info;
        NSData* response_data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
        if (response_data) {
            error_info = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:response_data options:NSJSONReadingMutableContainers error:nil];
        } else {
            error_info = @{@"message" : error.localizedDescription};
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RegistrationComplete" object:self userInfo:error_info];
    }];
}

- (void)forgotPassword {
    [[RxClient sharedClient] POST:kRxForgotPasswordEndpoint parameters:@{@"pt_email":_email} success:^(NSURLSessionDataTask *task, id responseObject) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PasswordRecoveryComplete" object:self userInfo:nil];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSDictionary* error_info = @{@"message" : @"Could not find user with supplied email."};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PasswordRecoveryComplete" object:self userInfo:error_info];
    }];
}

#pragma mark - Formatting/Parsing
/* Performs special formating on User parameters in order to match servers format requirements */
- (NSDictionary*)formatUserParams {
    NSDictionary *pt_data = @{@"pt_phone"       : _phone,
                              @"or_cash"        : (_has_insurance ? @"0" : @"1"),
                              @"pt_email"       : _email,
                              @"pt_country"     : _country,
                              @"pt_state"       : _state,
                              @"pt_address1"    : _address,
                              @"pt_address2"    : @"",
                              @"pt_city"        : _city,
                              @"pt_uname"       : _name,
                              @"or_regid"       : _device_id,
                              @"pt_deviceid"    : _device_id,
                              @"pt_zip"         : _zip};
    // Server expects pt_data value as string
    NSString *pt_data_string = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:pt_data options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    
    return @{@"pt_data" : pt_data_string};
}

- (void)parseRegistrationResponse:(NSDictionary*)response {
    NSDictionary *data = response[@"pt_data"];
    NSDictionary *patient = data[@"patient"];
    _order_id = data[@"or_id"];
    _token = patient[@"pt_token"];
}

- (void)parseLoginResponse:(NSDictionary*)response {
    NSDictionary *data = response[@"pt_data"];
    _name = data[@"pt_uname"];
    _address = data[@"pt_address1"];
    _city = data[@"pt_city"];
    _state = data[@"pt_state"];
    _country = data[@"pt_country"];
    _zip = data[@"pt_zip"];
    _email = data[@"pt_email"];
    _phone = data[@"pt_phone"];
    _token = data[@"pt_token"];
    _password = data[@"pt_upass"];
    _has_insurance = [response[@"or_cash"] isEqual: @"0"];
}

# pragma mark - Validations

- (BOOL)validateEmail:(NSString*)email {
    NSString *emailRegex = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (BOOL)validatePhone:(NSString*)phone {
    // valid = 10 digits and only integers
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if ([phone rangeOfCharacterFromSet:notDigits].location == NSNotFound)
        return phone.length == 10;
    return NO;
}

- (BOOL)validateLength:(NSString*)str {
    return str.length > 0;
}

@end
