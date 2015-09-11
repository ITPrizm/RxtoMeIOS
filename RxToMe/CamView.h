//
//  CamView.h
//  RxToMe
//
//  Created by Michael Spearman on 9/3/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVCaptureSession;
@interface CamView : UIView

@property (nonatomic) AVCaptureSession *session;

@end
