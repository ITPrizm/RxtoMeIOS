//
//  CamViewController.h
//  RxToMe
//
//  Created by Michael Spearman on 9/3/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class CamViewController;

@protocol CamViewDelegate <NSObject>

- (void)cameraVC:(CamViewController*)cameraVC selectedImage:(UIImage *)selectedImage;
- (void)cameraVCDidCancel:(CamViewController*)cameraVC;

@end

@interface CamViewController : UIViewController

@property (nonatomic, weak) id <CamViewDelegate> delegate;
@property BOOL alwaysLandscape;

@end
