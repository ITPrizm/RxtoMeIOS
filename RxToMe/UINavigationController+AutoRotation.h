//
//  UINavigationController+AutoRotation.h
//  RxToMe
//
//  Created by Michael Spearman on 9/4/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (AutoRotation)

-(NSUInteger)supportedInterfaceOrientations;

-(BOOL)shouldAutorotate;

@end
