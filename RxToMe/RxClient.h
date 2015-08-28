//
//  RxClient.h
//  RxToMe
//
//  Created by Michael Spearman on 8/14/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperationManager.h"

@interface RxClient : AFHTTPSessionManager

extern NSString* const kRxBaseURL;
extern NSString* const kRxLoginEndpoint;
extern NSString* const kRxNewUserEndpoint;
extern NSString* const kRxNewOrderEndpoint;
extern NSString* const kRxForgotPasswordEndpoint;

+ (id)sharedClient;

@end
