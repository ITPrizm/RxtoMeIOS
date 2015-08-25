//
//  RxClient.m
//  RxToMe
//
//  Created by Michael Spearman on 8/14/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import "RxClient.h"
#import "User.h"

NSString* const kRxBaseURL = @"http://api.rxtome.com/";
NSString* const kRxLoginEndpoint = @"api/v1/patient/login";
NSString* const kRxNewUserEndpoint = @"api/v1/patient/newuser";
NSString* const kRxNewOrderEndpoint = @"api/v1/patient/neworder";
NSString* const kRxForgotPasswordEndpoint = @"api/v1/patient/forgotpassword";

@implementation RxClient

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    [self.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [self.requestSerializer setValue:@"close" forHTTPHeaderField:@"Connection"];
    
    return self;
}

+ (id)sharedClient {
    static RxClient *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] initWithBaseURL:[NSURL URLWithString:kRxBaseURL]];
    });
    User *user = [User sharedManager];
    if (user.token != nil) {
        [sharedManager.requestSerializer setValue:user.token forHTTPHeaderField:@"pt_token"];
    }
    return sharedManager;
}

@end
