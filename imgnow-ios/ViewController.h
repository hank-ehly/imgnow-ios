//
//  ViewController.h
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/21.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@import MessageUI;

@interface ViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property AVCaptureSession *captureSession;
@property AVCaptureStillImageOutput *stillImageOutput;
@property AVCaptureDevice *captureDevise;
@property NSString *imageString;
@property UIImage *image;
@property AVCaptureVideoPreviewLayer *previewLayer;

@property UIAlertController *alertController;

@property bool facingFront;
@property bool flashIsOn;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *btnTakePhoto;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnSwitchCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
@property (weak, nonatomic) IBOutlet UIButton *btnToggleFlash;
@property (weak, nonatomic) IBOutlet UIButton *btnUpload;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *uploadActivityIndicator;

- (IBAction)takePhoto:(id)sender;
- (IBAction)switchCamera:(id)sender;
- (IBAction)upload:(id)sender;
- (IBAction)toggleFlash:(id)sender;
- (IBAction)retakePicture:(id)sender;

- (void)changeWindowState:(NSString *)state;
- (void)uploadAlertResultWithHtml:(NSString *)html;
- (void)sendEmail:(NSString*)message;

// Necessary for switch camera method
// Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position;

@end

