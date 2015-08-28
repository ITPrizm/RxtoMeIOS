//
//  CircularLoaderView.m
//  RxToMe
//
//  Created by Michael Spearman on 8/26/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import "CircularLoaderView.h"

const CGFloat circleRadius = 20.0;

@interface CircularLoaderView ()

@property (nonatomic) CAShapeLayer *circlePathLayer;

@end

@implementation CircularLoaderView
@synthesize progress;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)configure {
    _circlePathLayer = [CAShapeLayer layer];
    [self updateProgress:.1];
    _circlePathLayer.frame = self.bounds;
    _circlePathLayer.cornerRadius  = 10.0f;
    _circlePathLayer.lineWidth = 2;
    _circlePathLayer.fillColor = [[UIColor clearColor] CGColor];
    _circlePathLayer.strokeColor = [[UIColor colorWithRed:(46.0/255.0) green:(123.0/255.0) blue:(178.0/255.0) alpha:.8f] CGColor];
    _circlePathLayer.backgroundColor = [[UIColor colorWithWhite:.2f alpha:.3f] CGColor];
    [self.layer addSublayer:_circlePathLayer];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    [self resetProgress];
}

- (CGRect)circleFrame {
    CGRect circleFrame = CGRectMake(0, 0, 2*circleRadius, 2*circleRadius);
    circleFrame.origin.x = CGRectGetMidX(_circlePathLayer.bounds) - CGRectGetMidX(circleFrame);
    circleFrame.origin.y = CGRectGetMidY(_circlePathLayer.bounds) - CGRectGetMidY(circleFrame);
    return circleFrame;
}

- (UIBezierPath*)circlePath {
    return [UIBezierPath bezierPathWithOvalInRect:[self circleFrame]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _circlePathLayer.frame = self.bounds;
    _circlePathLayer.path = [[self circlePath] CGPath];
}

- (void)resetProgress {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _circlePathLayer.strokeEnd = .1;
    });
}

- (void)updateProgress:(CGFloat)frac {
    if (frac > .1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _circlePathLayer.strokeEnd = frac;
        });
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
