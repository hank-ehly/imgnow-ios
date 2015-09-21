//
//  ViewController.h
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/21.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController

@property AVCaptureSession *captureSession;
@property AVCaptureStillImageOutput *stillImageOutput;

@property UIAlertController *alertController;
@property UIAlertAction *alertActionHtmlOk;
@property UIAlertAction *alertActionSendEmail;
@property UIAlertAction *alertActionEmailOk;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *btnTakePhoto;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnSwitchCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
@property (weak, nonatomic) IBOutlet UIButton *btnFlashOff;
@property (weak, nonatomic) IBOutlet UIButton *btnUpload;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *uploadActivityIndicator;

- (IBAction)takePhoto:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)switchCamera:(id)sender;
- (IBAction)flashOff:(id)sender;
- (IBAction)upload:(id)sender;

- (void)changeWindowState:(NSString *)state;
- (void)uploadAlertResult;
- (void)sendEmail;

@end

