//
//  PhotoViewController.h
//  RxToMe
//
//  Created by Michael Spearman on 8/11/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CamViewController.h"

@interface PhotoViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UINavigationBarDelegate, CamViewDelegate>

@property (weak, nonatomic) NSString* type;

@end
