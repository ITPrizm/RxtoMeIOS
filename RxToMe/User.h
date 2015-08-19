//
//  UserModel.h
//  RxToMe
//
//  Created by Michael Spearman on 8/10/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface User : NSObject

+ (id)sharedManager;
- (BOOL)validateEmail:(NSString*)email;
- (BOOL)validatePhone:(NSString*)phone;
- (BOOL)validateLength:(NSString*)length;
- (void)login;
- (void)registerAccount;
- (void)createOrder;
- (void)forgotPassword;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *zip;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *device_id;
@property (strong, nonatomic) UIImage *prescription_image;
@property (strong, nonatomic) UIImage *insurance_front;
@property (strong, nonatomic) UIImage *insurance_back;
@property (strong, nonatomic) NSString *order_id;
@property (nonatomic) BOOL has_insurance;
@property (nonatomic) BOOL logged_in;

@end
