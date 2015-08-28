//
//  CircularLoaderView.h
//  RxToMe
//
//  Created by Michael Spearman on 8/26/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircularLoaderView : UIView

- (void)updateProgress:(CGFloat)frac;
@property (nonatomic) CGFloat progress;


@end
