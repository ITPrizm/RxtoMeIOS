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
    if (self = [super init]) {
//        _device_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"device_id"];
        _device_id = @"DEMO_DEVICE_ID";
        self.address = @"123 E. Newton St.";
        self.city = @"Gainsville";
        self.state = @"FL";
        self.zip = @"98761";
        self.country = @"USA";
        self.name = @"John Smith";
        self.email = @"jsmith@gmail.com";
        self.phone = @"5555555555";
        self.prescription_image = [UIImage imageNamed:@"prescription_blurred"];
    }
    return self;
}

#pragma mark - POST Requests

- (void)loginWithEmail:(NSString*)email password:(NSString*)password {
    NSString *params = [NSString stringWithFormat:@"pt_email=%@&pt_upass=%@", email, password];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://api.rxtome.com/api/v1/patient/login"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: [params dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSProgress *progress = nil;
    NSURLSessionUploadTask *uploadTask = [[RxClient sharedClient] uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"FAILURE: %@", response);
            NSDictionary* error_info;
            NSData* response_data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
            if (response_data) {
              error_info = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:response_data options:NSJSONReadingMutableContainers error:nil];
            } else {
              error_info = @{@"message" : error.localizedDescription};
            }

            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFailure"object:nil userInfo:error_info];
        } else {
            NSLog(@"SUCCESS: %@", response);
            _logged_in = YES;
            NSDictionary *response = (NSDictionary*)responseObject;
            // Pass response to user fields
            [self parseLoginResponse:response[@"data"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccess" object:nil userInfo:nil];
        }
    }];
    
    [progress addObserver:self
               forKeyPath:@"fractionCompleted"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    [uploadTask resume];
}

- (void)createOrder {
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"http://api.rxtome.com/api/v1/patient/neworder" parameters:[self formatUserParams] constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(_prescription_image, .5) name:@"pre_front" fileName:@"pre_front.jpeg" mimeType:@"image/jpeg"];
        if (_has_insurance) {
            [formData appendPartWithFileData:UIImageJPEGRepresentation(_insurance_front, .5) name:@"ins_front" fileName:@"ins_front.jpg" mimeType:@"image/jpeg"];
            [formData appendPartWithFileData:UIImageJPEGRepresentation(_insurance_back, .5) name:@"ins_back" fileName:@"ins_back.jpg" mimeType:@"image/jpeg"];
        }
    } error:nil];
    
    [request setValue:_token forHTTPHeaderField:@"pt_token"];
    
    NSProgress *progress = nil;
    
    NSURLSessionUploadTask *uploadTask = [[RxClient sharedClient] uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"FAILURE: %@", response);
            NSDictionary* error_info;
            NSData* response_data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
            if (response_data) {
                error_info = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:response_data options:NSJSONReadingMutableContainers error:nil];
            } else {
                error_info = @{@"message" : error.localizedDescription};
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"OrderCreated" object:self userInfo:error_info];
        } else {
            NSLog(@"SUCCESS: %@", response);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"OrderCreated" object:self userInfo:nil];
        }
    }];
    
    [progress addObserver:self
               forKeyPath:@"fractionCompleted"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    [uploadTask resume];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"fractionCompleted"] && [object isKindOfClass:[NSProgress class]]) {
        NSProgress *progress = (NSProgress *)object;
        NSDictionary *userInfo = @{@"progress":progress};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FractionCompleted" object:self userInfo:userInfo];
    }
}

- (void)registerAccount {
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"http://api.rxtome.com/api/v1/patient/newuser" parameters:[self formatUserParams] constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(_prescription_image, .3) name:@"pre_front" fileName:@"pre_front.jpeg" mimeType:@"image/jpeg"];
        if (_has_insurance) {
            [formData appendPartWithFileData:UIImageJPEGRepresentation(_insurance_front, .3) name:@"ins_front" fileName:@"ins_front.jpg" mimeType:@"image/jpeg"];
            [formData appendPartWithFileData:UIImageJPEGRepresentation(_insurance_back, .3) name:@"ins_back" fileName:@"ins_back.jpg" mimeType:@"image/jpeg"];
        }
    } error:nil];
    
    
    NSProgress *progress = nil;
    
    NSURLSessionUploadTask *uploadTask = [[RxClient sharedClient] uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"FAILURE: %@", response);
            NSDictionary* error_info;
            NSData* response_data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
            if (response_data) {
                error_info = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:response_data options:NSJSONReadingMutableContainers error:nil];
            } else {
                error_info = @{@"message" : error.localizedDescription};
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountRegistered" object:self userInfo:error_info];
        } else {
            NSLog(@"SUCCESS: %@", response);
            NSDictionary *response = (NSDictionary*)responseObject;
            // Pass response to user fields
            [self parseRegistrationResponse:response[@"data"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountRegistered" object:self userInfo:nil];
        }
    }];
    
    [progress addObserver:self
               forKeyPath:@"fractionCompleted"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    [uploadTask resume];
}


- (void)forgotPasswordForEmail:(NSString*)email {
    NSString *params = [NSString stringWithFormat:@"pt_email=%@", email];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://api.rxtome.com/api/v1/patient/forgotpassword"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: [params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSProgress *progress = nil;
    NSURLSessionUploadTask *uploadTask = [[RxClient sharedClient] uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"FAILURE: %@", response);
            NSDictionary* error_info = @{@"message" : @"Could not find user with supplied email."};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PasswordRecoveryComplete" object:self userInfo:error_info];
        } else {
            NSLog(@"SUCCESS: %@", response);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PasswordRecoveryComplete" object:self userInfo:nil];
        }
    }];
    
    [progress addObserver:self
               forKeyPath:@"fractionCompleted"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    [uploadTask resume];
}



#pragma mark - Formatting/Parsing
/* Performs special formating on User parameters in order to match server's formating requirements */
- (NSDictionary*)formatUserParams {
    NSDictionary *pt_data = @{@"pt_phone"       : _phone,
                              @"or_cash"        : (_has_insurance ? @"0" : @"1"),
                              @"pt_email"       : _email,
                              @"pt_country"     : _country,
                              @"pt_state"       : _state,
                              @"pt_address1"    : _address,
                              @"pt_address2"    : _address2,
                              @"pt_city"        : _city,
                              @"pt_uname"       : _name,
                              @"or_regid"       : _device_id,
                              @"pt_deviceid"    : _device_id,
                              @"pt_zip"         : _zip,
                              @"pt_devicetype"  : @"ios"};
    // Server expects pt_data value as string
    NSString *pt_data_string = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:pt_data options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    pt_data_string = [pt_data_string stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    return @{@"pt_data" : pt_data_string};
}

- (void)parseRegistrationResponse:(NSDictionary*)response {
    NSDictionary *data = response[@"pt_data"];
    NSDictionary *patient = data[@"patient"];
    _token = patient[@"pt_token"];
}

- (void)parseLoginResponse:(NSDictionary*)response {
    NSDictionary *data = response[@"pt_data"];
    _name = data[@"pt_uname"];
    _address = data[@"pt_address1"];
    _address2 = data[@"pt_address2"];
    _city = data[@"pt_city"];
    _state = data[@"pt_state"];
    _country = data[@"pt_country"];
    _zip = data[@"pt_zip"];
    _email = data[@"pt_email"];
    _phone = data[@"pt_phone"];
    _token = data[@"pt_token"];
    _password = data[@"pt_upass"];
    _insurance_back = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat: @"%@%@", kRxBaseURL, data[@"pt_insback"]]]]];
    _insurance_front = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat: @"%@%@", kRxBaseURL, data[@"pt_insfront"]]]]];
    _has_insurance = [response[@"or_cash"] isEqual: @"0"];
}

- (void)empty {
    _name = nil;
    _address = nil;
    _address2 = nil;
    _city = nil;
    _state = nil;
    _country = nil;
    _zip = nil;
    _email = nil;
    _phone = nil;
    _token = nil;
    _password = nil;
    _insurance_back = nil;
    _insurance_front = nil;
    _prescription_image = nil;
    _logged_in = NO;
    _token = nil;
}

# pragma mark - Validations

- (BOOL)validateEmail:(NSString*)email {
    if ([self onlyWhiteSpace:email]) return NO;
    NSString *emailRegex = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (BOOL)validatePhone:(NSString*)phone {
    // valid = 10 digits
    if (phone.length != 14) return NO;
    char c;
    NSCharacterSet *phone_chars = [NSCharacterSet characterSetWithCharactersInString:@"1234567890()- "];
    for (int i = 0; i < phone.length; i++) {
        // strip special chars
        c =  [phone characterAtIndex:i];
        if (![phone_chars characterIsMember:c]) return NO;
    }
    if (!([phone characterAtIndex:0] == '(')) {
        return NO;
    } else if (!([phone characterAtIndex:4] == ')')) {
        return NO;
    } else if (!([phone characterAtIndex:5] == ' ')) {
        return NO;
    } else if (!([phone characterAtIndex:9] == '-')) {
        return NO;
    }
    return YES;
}

- (BOOL)validateZip:(NSString*)zip {
    // must be 5 integers
    return [self allChars:zip withLength:5];
}

- (BOOL)validatePostalCode:(NSString*)code {
    // valid if follows format A#A#A#
    if (code.length != 6) return NO;
    NSCharacterSet *letters = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
    for (int i = 0; i < code.length; i++) {
        char c = [code characterAtIndex:i];
        // even vs odd
        if (i % 2) {
            // check if int
            if (![numbers characterIsMember:c]) return false;
        } else {
            // check if letter
            if (![letters characterIsMember:c]) return false;
        }
    }
    return YES;
}

- (BOOL)onlyWhiteSpace:(NSString*)string{
    int i = 0;
    while (i < string.length) {
        char c = [string characterAtIndex:i];
        if (![[NSCharacterSet whitespaceCharacterSet] characterIsMember:c]) return NO;
        i++;
    }
    return YES;
}

- (BOOL)allChars:(NSString*)string withLength:(NSInteger)length {
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if ([string rangeOfCharacterFromSet:notDigits].location == NSNotFound)
        return string.length == length;
    return NO;
}

- (BOOL)validateLength:(NSString*)str {
    if ([self onlyWhiteSpace:str]) return NO;
    return str.length > 0;
}

@end
