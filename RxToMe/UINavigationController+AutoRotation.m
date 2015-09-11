//
//  UINavigationController+AutoRotation.m
//  RxToMe
//
//  Created by Michael Spearman on 9/4/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import "UINavigationController+AutoRotation.h"

@implementation UINavigationController (AutoRotation)

-(NSUInteger)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}

-(BOOL)shouldAutorotate {
    return YES;
}

@end
