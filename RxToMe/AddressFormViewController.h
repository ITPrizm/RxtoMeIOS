//
//  AddressFormViewController.h
//  RxToMe
//
//  Created by Michael Spearman on 8/12/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AddressFormViewController : UIViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource,CLLocationManagerDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>
@property BOOL is_modal;
@end
