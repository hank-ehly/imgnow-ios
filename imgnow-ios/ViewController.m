//
//  ViewController.m
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/21.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Api.h"
@import MessageUI;

@interface ViewController ()

@end

@implementation ViewController

@synthesize alertController;
@synthesize captureDevise;
@synthesize captureSession;
@synthesize image;
@synthesize imageString;
@synthesize previewLayer;
@synthesize stillImageOutput;

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void) setupCamera {
  
  _torchIsOn = NO;
  _facingFront = NO;
  [self turnTorchOn:NO];
  [self changeWindowState:@"pretake"];
  
  captureSession = [[AVCaptureSession alloc] init];
  captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
  
  NSError *error = nil;
  captureDevise = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  
  AVCaptureDeviceInput *captureDeviseInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevise error:&error];
  
  if ([captureSession canAddInput:captureDeviseInput]) {
    [captureSession addInput:captureDeviseInput];
  }
  
  previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
  previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
  CGRect bounds = self.view.bounds;
  previewLayer.frame = self.view.bounds;
  previewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
  [self.view.layer insertSublayer:previewLayer atIndex:0];
  
  stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
  NSDictionary *stillImageOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
  stillImageOutput.outputSettings = stillImageOutputSettings;
  
  if ([captureSession canAddOutput:stillImageOutput]) {
    [captureSession addOutput:stillImageOutput];
  }
  
  [captureSession startRunning];
  
}

// gotta have this to fully update previewLayer on screen rotation
- (void)viewWillLayoutSubviews {
  previewLayer.frame = self.view.bounds;
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  long orientation = [[UIDevice currentDevice] orientation];
  
  switch (orientation) {
    case 1:
      [previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
      break;
    case 2:
      break;
    case 3:
      [previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
      break;
    case 4:
      [previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
      break;
  }
  
}

- (void)viewWillAppear:(BOOL)animated {
  
  if (![captureSession isRunning]) {
    [self setupCamera];
  }
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  // If the user has just logged in or registered
  if ([defaults valueForKey:@"status"] != nil) {
    
    // configure alert text
    NSString *alertTitle = [[NSString alloc] init];
    NSString *uid = [defaults valueForKey:@"user_email"];
    NSString *alertMessage = [NSString stringWithFormat:@"Welcome, %@", uid];
    NSString *acceptTitle = NSLocalizedStringFromTable(@"defaultAcceptTitle", @"AlertStrings", nil);
    
    // status in integer format
    long status = [[defaults valueForKey:@"status"] integerValue];
    
    // 1 : user just logged in
    // 2 : user just registered
    switch (status) {
      case 1:
        alertTitle = NSLocalizedStringFromTable(@"loginSuccess", @"AlertStrings", nil);
        break;
      case 2:
        alertTitle = NSLocalizedStringFromTable(@"registrationSuccess", @"AlertStrings", nil);
        break;
    }
    
    // configure alert controller
    alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                          message:alertMessage
                                                   preferredStyle:UIAlertControllerStyleAlert];
    
    // accept action
    UIAlertAction *actionAccept = [UIAlertAction actionWithTitle:acceptTitle
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
    
    // add action to alert controller
    [alertController addAction:actionAccept];
    
    // remove 'status' so that the alert doesn't show up
    // every time you come back to this view
    [self presentViewController:alertController animated:YES completion:^{
      [defaults removeObjectForKey:@"status"];
    }];
    
  }
}

- (IBAction)switchCamera:(id)sender
{
  //Change camera source
  if(captureSession) {
    //Indicate that some changes will be made to the session
    [captureSession beginConfiguration];
    
    //Remove existing input
    AVCaptureInput *currentCameraInput = [captureSession.inputs objectAtIndex:0];
    [captureSession removeInput:currentCameraInput];
    
    //Get new input
    AVCaptureDevice *newCamera = nil;
    if(((AVCaptureDeviceInput*)currentCameraInput).device.position == AVCaptureDevicePositionBack) {
      newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
      self.imageView.transform = CGAffineTransformMakeScale(-1, 1);
      _facingFront = YES;
      self.btnToggleFlash.hidden  = YES;
    } else {
      newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
      self.imageView.transform = CGAffineTransformMakeScale(1, 1);
      self.btnToggleFlash.hidden  = NO;
      _facingFront = NO;
    }
    
    //Add input to session
    NSError *err = nil;
    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:&err];
    if(!newVideoInput || err) {
      NSLog(@"Error creating capture device input: %@", err.localizedDescription);
    } else {
      [captureSession addInput:newVideoInput];
    }
    
    //Commit all the configuration changes at once
    [captureSession commitConfiguration];
  }
}

// needed for switch camera method
// Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
  NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
  for (AVCaptureDevice *device in devices)
  {
    if ([device position] == position) return device;
  }
  return nil;
}


- (IBAction)takePhoto:(id)sender {
  
  AVCaptureConnection *videoConnection = nil;
  
  for (AVCaptureConnection *connection in stillImageOutput.connections) {
    for (AVCaptureInputPort *port in connection.inputPorts) {
      if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
        videoConnection = connection;
        break;
      }
    }
    if (videoConnection) {
      break;
    }
  }
  
  [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
    
    if (imageDataSampleBuffer != NULL) {
      
      NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
      
      imageString = [NSString stringWithFormat:@"%@", imageData];
      imageString = [imageString stringByReplacingOccurrencesOfString:@" " withString:@""];
      imageString = [imageString substringWithRange:NSMakeRange(1, [imageString length] - 2)];
      
      image = [UIImage imageWithData:imageData];
      self.imageView.image = image;
      [self changeWindowState:@"posttake"];
      
    }
  }];
  
}

- (IBAction)upload:(id)sender {
  
  // loading wheel
  [self.uploadActivityIndicator startAnimating];
  
  NSString *uid = [[NSUserDefaults standardUserDefaults] valueForKey:@"user_email"];
  NSMutableURLRequest *request = [Api createImageRequest:imageString forUser:uid];
  
  [Api fetchContentsOfRequest:request
                   completion:^(NSData *data, NSURLResponse *response, NSError *error) {
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                       
                       if (error) {
                         // handle error
                       }
                       
                       switch ([Api statusCodeForResponse:response]) {
                         case 200:
                           [self imageCreateSuccess:data];
                           break;
                         default:
                           NSLog(@"Status code %ld wasn't accounted for in ViewController.m upload",
                                 [Api statusCodeForResponse:response]);
                           break;
                       }
                       
                     });
                     
                   }];
  
}

#pragma mark - Async Completion

- (void)imageCreateSuccess:(NSData*)data {
  NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  [self.uploadActivityIndicator stopAnimating];
  [self uploadAlertResultWithHtml:[NSString stringWithFormat:@"%@%@", [Api fetchBaseRouteString], [json valueForKey:@"url"]]];
}

- (void)uploadAlertResultWithHtml:(NSString *)html {
  
  // configure alert titles
  NSString *alertTitle = NSLocalizedStringFromTable(@"uploadSuccessAlertTitle", @"AlertStrings", nil);
  NSString *acceptTitle = NSLocalizedStringFromTable(@"defaultAcceptTitle", @"AlertStrings", nil);
  NSString *sendEmailTitle = NSLocalizedStringFromTable(@"sendEmailTitle", @"AlertStrings", nil);
  
  // configure alert controller
  alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                        message:html
                                                 preferredStyle:UIAlertControllerStyleAlert];
  
  // accept action
  UIAlertAction *actionAccept = [UIAlertAction actionWithTitle:acceptTitle
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil];
  
  // send email action
  UIAlertAction *actionSendEmail =
  [UIAlertAction actionWithTitle:sendEmailTitle
                           style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * _Nonnull action) {
                           
                           [self sendEmail:[Api imgTagWithSrc:html]];
                         }];
  
  // save to camera roll action
  UIAlertAction *actionSave =
  [UIAlertAction actionWithTitle:@"Save to CameraRoll"
                           style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * _Nonnull action) {
                           
                           UIImageWriteToSavedPhotosAlbum(image, self, @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), NULL);
                         }];
  
  // add each action to the alert controller
  [alertController addAction:actionAccept];
  [alertController addAction:actionSendEmail];
  [alertController addAction:actionSave];
  
  [self presentViewController:alertController animated:YES completion:nil];
  
  [self changeWindowState:@"pretake"];
  
}

- (void)thisImage:(UIImage *)image
hasBeenSavedInPhotoAlbumWithError:(NSError *)error
 usingContextInfo:(void*)ctxInfo {
  
  // alert controller titles / actions strings
  NSString *alertTitle = [[NSString alloc] init];
  NSString *alertMessage = [[NSString alloc] init];
  NSString *acceptTitle = NSLocalizedStringFromTable(@"defaultAcceptTitle", @"AlertStrings", nil);
  
  // set strings based on whether there is an error
  if (error) {
    alertTitle = NSLocalizedStringFromTable(@"defaultFailureTitle", @"AlertStrings", nil);
    alertMessage = NSLocalizedStringFromTable(@"saveToCameraRollFailure", @"AlertStrings", nil);
  } else {
    alertTitle = nil;
    alertMessage = NSLocalizedStringFromTable(@"saveToCameraRollSuccess", @"AlertStrings", nil);
    
  }
  
  // configure alert controller
  alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                        message:alertMessage
                                                 preferredStyle:UIAlertControllerStyleAlert];
  
  // accept action
  UIAlertAction *actionAccept = [UIAlertAction actionWithTitle:acceptTitle
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil];
  
  [alertController addAction:actionAccept];
  
  [self presentViewController:alertController animated:YES completion:nil];
  
}



- (void)sendEmail:(NSString *)message {
  
  MFMailComposeViewController *mfvc = [[MFMailComposeViewController alloc] init];
  [mfvc setMailComposeDelegate:self];
  [mfvc setToRecipients:[NSArray arrayWithObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"user_email"]]];
  [mfvc setSubject:@"message from outer space"];
  [mfvc setMessageBody:message isHTML:NO];
  
  if ([MFMailComposeViewController canSendMail]) {
    
    [self presentViewController:mfvc animated:YES completion:nil];
    
  } else {
    
    // configure alert strings
    NSString *alertTitle = NSLocalizedStringFromTable(@"defaultFailureTitle", @"AlertStrings", nil);
    NSString *alertMessage = NSLocalizedStringFromTable(@"openMailFailureMessage", @"AlertStrings", nil);
    NSString *acceptTitle = NSLocalizedStringFromTable(@"defaultAcceptTitle", @"AlertStrings", nil);
    
    // configure alert controller
    alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                          message:alertMessage
                                                   preferredStyle:UIAlertControllerStyleAlert];
    
    // accept action
    UIAlertAction *actionAccept = [UIAlertAction actionWithTitle:acceptTitle
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
    
    [alertController addAction:actionAccept];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
  }
  
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
  [controller dismissViewControllerAnimated:YES completion:^{
    
    dispatch_async(dispatch_get_main_queue(), ^{
      [self changeWindowState:@"pretake"];
    });
    
  }];
}

- (IBAction)cancel:(id)sender {
  [self changeWindowState:@"pretake"];
}

- (IBAction)toggleFlash:(id)sender {
  if (!_torchIsOn) {
    [self turnTorchOn:YES];
    [_btnToggleFlash setImage:[UIImage imageNamed:@"Flash-On-50-white.png"] forState:UIControlStateNormal];
  } else {
    [self turnTorchOn:NO];
    [_btnToggleFlash setImage:[UIImage imageNamed:@"Flash Off-50 (1).png"] forState:UIControlStateNormal];
  }
}

- (void) turnTorchOn: (bool) on {
  
  Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
  if (captureDeviceClass != nil) {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch] && [device hasFlash]){
      
      [device lockForConfiguration:nil];
      if (on) {
        [device setFlashMode:AVCaptureFlashModeOn];
        _torchIsOn = YES;
      } else {
        [device setFlashMode:AVCaptureFlashModeOff];
        _torchIsOn = NO;
      }
      [device unlockForConfiguration];
    }
  }
}

- (void)changeWindowState:(NSString *)state {
  
  if ([state isEqualToString:@"pretake"]) {
    self.btnCancel.hidden               = YES;
    self.imageView.hidden               = YES;
    self.btnUpload.hidden               = YES;
    self.btnTakePhoto.hidden            = NO;
    self.btnSwitchCamera.hidden         = NO;
    self.btnMenu.hidden                 = NO;
    self.btnToggleFlash.hidden = _facingFront ? YES : NO;
  } else if ([state isEqualToString:@"posttake"]) {
    self.btnCancel.hidden       = NO;
    self.imageView.hidden       = NO;
    self.btnUpload.hidden       = NO;
    self.btnTakePhoto.hidden    = YES;
    self.btnSwitchCamera.hidden = YES;
    self.btnMenu.hidden         = YES;
    self.btnToggleFlash.hidden = _facingFront ? YES : NO;
  }
  
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
