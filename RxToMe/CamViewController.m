//
//  CamViewController.m
//  RxToMe
//
//  Created by Michael Spearman on 9/3/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import "CamViewController.h"
#import "CamView.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "FontAwesomeKit/FontAwesomeKit.h"

@interface CamViewController ()

@property (weak, nonatomic) IBOutlet CamView *previewView;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (weak, nonatomic) IBOutlet UIButton *retakeButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (nonatomic) UIImage *capturedImage;
@property (nonatomic) UIImageView *imagePreview;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (nonatomic) UIImage *croppedImage;
@property BOOL lockInterface;

@end

@implementation CamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [self setSession:session];
    [[self previewView] setSession:session];
    self.imagePreview = [[UIImageView alloc] init];
    self.imagePreview.frame = self.view.frame;
    self.imagePreview.contentMode = UIViewContentModeScaleAspectFit;
    [self.view insertSubview:self.imagePreview belowSubview:self.previewView];
    
    // Initializing camera in a landscape orientation. This is beacuse no rotatation is done when in portrait/upsidedown mode and alwaysLandscape is true.
    [self.captureButton setImage:[[FAKIonIcons ios7CameraIconWithSize:60] imageWithSize:CGSizeMake(50, 50)] forState:UIControlStateNormal];
    [self.cancelButton setImage:[[FAKFoundationIcons xIconWithSize:60] imageWithSize:CGSizeMake(50, 50)] forState:UIControlStateNormal];
    [self.doneButton setImage:[[FAKFontAwesome saveIconWithSize:60] imageWithSize:CGSizeMake(50, 50)] forState:UIControlStateNormal];
    [self.retakeButton setImage:[[FAKFoundationIcons xIconWithSize:60] imageWithSize:CGSizeMake(50, 50)] forState:UIControlStateNormal];
    self.captureButton.transform = CGAffineTransformRotate(self.captureButton.transform, M_PI_2);
    self.doneButton.transform = CGAffineTransformRotate(self.doneButton.transform, M_PI_2);
    self.imagePreview.transform = CGAffineTransformRotate(self.imagePreview.transform, M_PI_2);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
    
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue];
    
    dispatch_async(sessionQueue, ^{
        NSError *error = nil;
        AVCaptureDevice *videoDevice = [CamViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        if (error)
            NSLog(@"%@", error);
        
        if ([[self session] canAddInput:videoDeviceInput])
            [[self session] addInput:videoDeviceInput];
        
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([session canAddOutput:stillImageOutput]) {
            [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
            [session addOutput:stillImageOutput];
            [self setStillImageOutput:stillImageOutput];
            // Update the orientation on the still image output video connection.
            [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:(AVCaptureVideoOrientation)UIDeviceOrientationLandscapeLeft];
        }
    });
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    dispatch_async([self sessionQueue], ^{
        [[self session] stopRunning];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self enablePreviewMode:NO];
    [self setLockInterface:NO];
    [self deviceDidRotate:nil];
    dispatch_async([self sessionQueue], ^{
        [[self session] startRunning];
    });
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            captureDevice = device;
            break;
        }
    }
    return captureDevice;
}

- (IBAction)doneButtonPressed:(id)sender {
    [self.delegate cameraVC:self selectedImage:self.croppedImage];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self.delegate cameraVCDidCancel:self];
}


- (IBAction)retakeButtonPressed:(id)sender {
    self.lockInterface = NO;
    [self enablePreviewMode:NO];
}

- (void)enablePreviewMode:(BOOL)enable {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.previewView.hidden = enable;
        self.captureButton.hidden = enable;
        self.cancelButton.hidden = enable;
        self.retakeButton.hidden = !enable;
        self.doneButton.hidden = !enable;
        self.imagePreview.hidden = !enable;
    });
}

- (void)deviceDidRotate:(NSNotification *)notification {
    if (self.lockInterface) return;
    AVCaptureVideoOrientation currentOrientation = (AVCaptureVideoOrientation)[[UIDevice currentDevice] orientation];
    double rotation = 0;
    switch (currentOrientation) {
        case UIDeviceOrientationPortrait:
            if (self.alwaysLandscape) return;
            rotation = 0;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            if (self.alwaysLandscape) return;
            rotation = -M_PI;
            break;
        case UIDeviceOrientationLandscapeLeft:
            rotation = M_PI_2;
            break;
        case UIDeviceOrientationLandscapeRight:
            rotation = -M_PI_2;
            break;
        default:
            // Face-Up/Face-Down/Unknown are not part of AVCaptureVideoOrientation enum
            return;
    }
    CGAffineTransform transform = CGAffineTransformMakeRotation(rotation);
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.captureButton setTransform:transform];
        [self.doneButton setTransform:transform];
        [self.retakeButton setTransform:transform];
        [self.imagePreview setTransform:transform];
    } completion:^(BOOL finished) {
        dispatch_async([self sessionQueue], ^{
            // Update the orientation on the still image output video connection before capturing.
            [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:(AVCaptureVideoOrientation)currentOrientation];
        });
    }];
}

- (IBAction)captureButtonPressed:(id)sender {
    dispatch_async([self sessionQueue], ^{
        self.lockInterface = YES;
        // Flash set to Auto for Still Capture
        // [AVCamViewController setFlashMode:AVCaptureFlashModeAuto forDevice:[[self videoDeviceInput] device]];
        
        // Capture a still image.
        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
            if (imageDataSampleBuffer) {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                self.capturedImage = [[UIImage alloc] initWithData:imageData];
                self.croppedImage = [self cropLongestSide:self.capturedImage];
                self.imagePreview.frame = self.view.frame;
                self.imagePreview.image = self.capturedImage;
                [self enablePreviewMode:YES];
            }
        }];
    });
}

- (UIImage*)cropLongestSide:(UIImage*)original_image {
    UIImage *cropped_image;
    double offset = 0;
    // crop origin offset depends on orientation
    if (original_image.imageOrientation == UIImageOrientationDown ||
        original_image.imageOrientation == UIImageOrientationLeft)
        offset = MAX(original_image.size.width, original_image.size.height)/5;
    if (original_image.size.height > original_image.size.width) {
        CGRect crop = CGRectMake(0, offset, original_image.size.width, original_image.size.height*5/6);
        UIGraphicsBeginImageContextWithOptions(crop.size, false, [original_image scale]);
        [original_image drawAtPoint:CGPointMake(-crop.origin.x, -crop.origin.y)];
        cropped_image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    } else {
        CGRect crop = CGRectMake(offset, 0, original_image.size.width*5/6 ,original_image.size.height);
        UIGraphicsBeginImageContextWithOptions(crop.size, false, [original_image scale]);
        [original_image drawAtPoint:CGPointMake(-crop.origin.x, -crop.origin.y)];
        cropped_image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return cropped_image;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
