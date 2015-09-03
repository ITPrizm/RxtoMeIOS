//
//  UIView+FindFirstResponder.m
//  RxToMe
//
//  Created by Michael Spearman on 9/1/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import "UIView+FindFirstResponder.h"

@implementation UIView (FindFirstResponder)
- (id)findFirstResponder
{
    if (self.isFirstResponder) {
        return self;
    }
    for (UIView *subView in self.subviews) {
        id responder = [subView findFirstResponder];
        if (responder) return responder;
    }
    return nil;
}
@end