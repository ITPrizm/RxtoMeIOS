//
//  ModelController.h
//  RxToMe
//
//  Created by Michael Spearman on 8/9/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataViewController;

@interface ModelController : NSObject <UIPageViewControllerDataSource>

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(DataViewController *)viewController;

@end

