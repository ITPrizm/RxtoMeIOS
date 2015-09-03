//
//  NSString+PhoneFormating.m
//  RxToMe
//
//  Created by Michael Spearman on 9/2/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import "NSString+PhoneFormating.h"

@implementation NSString (PhoneFormating)

// Adds special character to phone number
- (NSString*)stringToPhone {
    if (self.length == 0) return nil;
    NSString *area_code;
    NSString *prefix;
    NSString *suffix;
    area_code = [self substringToIndex:3];
    prefix = [self substringWithRange:NSMakeRange(3, 3)];
    suffix = [self substringFromIndex:6];
    return [NSString stringWithFormat:@"(%@) %@-%@", area_code, prefix, suffix];
}

// Removes special characters from phone number
- (NSString*)phoneToString {
    NSMutableString* phone_format = [[NSMutableString alloc] init];
    NSCharacterSet *specials = [NSCharacterSet characterSetWithCharactersInString:@"()- "];
    for (int i = 0; i < self.length; i++) {
        char c = [self characterAtIndex:i];
        if (![specials characterIsMember:c]) {
            [phone_format appendFormat:@"%c", c];
        }
    }
    return phone_format;
}

@end
