//
//  CamView.m
//  RxToMe
//
//  Created by Michael Spearman on 9/3/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import "CamView.h"
#import <AVFoundation/AVFoundation.h>

@implementation CamView

+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession*)session {
    return [(AVCaptureVideoPreviewLayer *)[self layer] session];
}

- (void)setSession:(AVCaptureSession *)session {
    [(AVCaptureVideoPreviewLayer *)[self layer] setSession:session];
}

@end
