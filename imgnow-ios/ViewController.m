//
//  ViewController.m
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/21.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
@import MessageUI;

@interface ViewController ()

@end

@implementation ViewController

@synthesize stillImageOutput;
@synthesize captureSession;
@synthesize alertActionHtmlOk;
@synthesize alertController;
@synthesize alertActionSendEmail;
@synthesize alertActionEmailOk;
@synthesize captureDevise;

NSString *imageString;
UIImage *image;
AVCaptureVideoPreviewLayer *previewLayer;


- (void)viewDidLoad {
    [super viewDidLoad];
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

//
//- (BOOL)shouldAutorotate {
//    id currentViewController = self.topViewController;
//    
//    if ([currentViewController isKindOfClass:[DetailViewController class]])
//        return NO;
//    
//    return YES;
//}


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
        default:
            NSLog(@"Orientation unknown");
            break;
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults valueForKey:@"welcomeMessage"]) {
        
        NSString *msg = [NSString stringWithFormat:@"Welcome, %@", [defaults valueForKey:@"user_email"]];
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:[[NSUserDefaults standardUserDefaults] valueForKey:@"welcomeMessage"] message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
        [ac addAction:ok];
        [self presentViewController:ac animated:YES completion:^{
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"welcomeMessage"];
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
    
    // set url
    NSString *routesFile = [[NSBundle mainBundle] pathForResource:@"api-routes" ofType:@"plist"];
    NSDictionary *routes = [NSDictionary dictionaryWithContentsOfFile:routesFile];
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [routes objectForKey:@"base"], [routes objectForKey:@"api_images_create"]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // loading wheel
    self.uploadActivityIndicator.hidden = NO;
    [self.uploadActivityIndicator startAnimating];
    
    NSString *email = [[NSUserDefaults standardUserDefaults] valueForKey:@"user_email"];
    
    // format data
    NSString *imgStr = [NSString stringWithFormat:@"{\"image\": \"%@\",\"authenticity_token\": \"\", \"utf8\": \"✓\",\"email\":\"%@\"}", imageString, email];
    NSData   *data   = [imgStr dataUsingEncoding:NSUTF8StringEncoding];
    
    // http request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:data];
    
    // ajax
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        [self.uploadActivityIndicator stopAnimating];
        [self uploadAlertResultWithHtml:[NSString stringWithFormat:@"%@%@", [routes valueForKey:@"base"], [json valueForKey:@"url"]]];
        
    }];
    
}

- (void)uploadAlertResultWithHtml:(NSString *)html {
    
    NSString *title   = @"Plug this into your HTML";
    NSString *message = html;
    NSString *titleOk = @"OK";
    NSString *titleEmail = @"Email it to me";
    
    alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    alertActionHtmlOk = [UIAlertAction actionWithTitle:titleOk style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // do nothing
    }];
    
    alertActionSendEmail = [UIAlertAction actionWithTitle:titleEmail style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // send email
        NSString *beg = @"<img src=\"";
        NSString *end = @"\"></img>";
        NSString *body = [NSString stringWithFormat:@"%@%@%@", beg, html, end];
        [self sendEmail:body];
    }];
    
    UIAlertAction *saveToCameraRoll = [UIAlertAction actionWithTitle:@"Save to CameraRoll" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        // get img
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), NULL);
    }];
    
    [alertController addAction:alertActionHtmlOk];
    [alertController addAction:alertActionSendEmail];
    [alertController addAction:saveToCameraRoll];
    
    [self presentViewController:alertController animated:YES completion:nil];

    [self changeWindowState:@"pretake"];
    
}

- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {
    if (error) {
        NSLog(@"%@", error);
        // error
        alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Unable to save to camera roll. Please try again." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionDownloadOk = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // did press ok
        }];
        
        [alertController addAction:actionDownloadOk];
        
        [self presentViewController:alertController animated:YES completion:^{
            // presented view controller
        }];
    } else {
        // saved successfully
        alertController = [UIAlertController alertControllerWithTitle:nil message:@"Downloaded to CameraRoll" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionDownloadOk = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // did press ok
        }];
        
        [alertController addAction:actionDownloadOk];
        
        [self presentViewController:alertController animated:YES completion:^{
            // presented view controller
        }];
    }
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
        NSString *title = @"Could Not Send Email";
        NSString *message = @"Your device could not send e-mail. Please check your e-mail configuration and try again";
        alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        alertActionEmailOk = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // pressed ok
        }];
        [alertController addAction:alertActionEmailOk];
        [self presentViewController:alertController animated:YES completion:^{
            // showed email sent alert
        }];
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
        self.uploadActivityIndicator.hidden = YES;
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
