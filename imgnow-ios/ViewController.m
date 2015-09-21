//
//  ViewController.m
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/21.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@end

@implementation ViewController

@synthesize stillImageOutput;
@synthesize captureSession;
@synthesize alertActionHtmlOk;
@synthesize alertController;
@synthesize alertActionSendEmail;
@synthesize alertActionEmailOk;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self changeWindowState:@"pretake"];
    
    captureSession = [[AVCaptureSession alloc] init];
    captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    NSError *error = nil;
    AVCaptureDevice *captureDevise = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *captureDeviseInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevise error:&error];
    
    [captureSession canAddInput:captureDeviseInput] ? [captureSession addInput:captureDeviseInput] : NULL;
    
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    CGRect bounds = self.view.layer.bounds;
    previewLayer.bounds = bounds;
    previewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    [self.view.layer insertSublayer:previewLayer atIndex:0];
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *stillImageOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    stillImageOutput.outputSettings = stillImageOutputSettings;
    
    [captureSession canAddOutput:stillImageOutput] ? [captureSession addOutput:stillImageOutput] : NULL;
    
    [captureSession startRunning];
    
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
            UIImage *image = [UIImage imageWithData:imageData];
            self.imageView.image = image;
            
            [self changeWindowState:@"posttake"];
        }
    }];
    
}

- (IBAction)cancel:(id)sender {
    [self changeWindowState:@"pretake"];
}

- (IBAction)switchCamera:(id)sender {
}

- (IBAction)goToImageList:(id)sender {
}

- (IBAction)flashOff:(id)sender {
}

- (IBAction)upload:(id)sender {
    
    self.uploadActivityIndicator.hidden = NO;
    [self.uploadActivityIndicator startAnimating];
    
    // perform the actual upload
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(uploadAlertResult) userInfo:nil repeats:NO];
    
}

-(void)uploadAlertResult {
    
    NSString *title   = @"Plug this into your HTML";
    NSString *message = @"<img src=\"http://placeholdnow.com/4j8d92je.jpeg\">";
    NSString *titleOk = @"OK";
    NSString *titleEmail = @"Email it to me";
    
    alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    alertActionHtmlOk = [UIAlertAction actionWithTitle:titleOk style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // do nothing
    }];
    
    alertActionSendEmail = [UIAlertAction actionWithTitle:titleEmail style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // send email
        [self sendEmail];
    }];
    
    [alertController addAction:alertActionHtmlOk];
    [alertController addAction:alertActionSendEmail];
    
    [self presentViewController:alertController animated:YES completion:nil];

    [self changeWindowState:@"pretake"];
    
}

- (void)sendEmail {

    alertController = [UIAlertController alertControllerWithTitle:@"heyhey" message:@"whwhw" preferredStyle:UIAlertControllerStyleAlert];
    alertActionEmailOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //
    }];
    [alertController addAction:alertActionEmailOk];
    [self presentViewController:alertController animated:YES completion:^{
        //
    }];
    
}


-(void)changeWindowState:(NSString *)state {
    
    if ([state isEqualToString:@"pretake"]) {
        self.btnCancel.hidden = YES;
        self.imageView.hidden = YES;
        self.btnUpload.hidden = YES;
        self.uploadActivityIndicator.hidden = YES;
        self.btnTakePhoto.hidden = NO;
        self.btnSwitchCamera.hidden = NO;
        self.btnMenu.hidden = NO;
        self.btnFlashOff.hidden = NO;
    } else if ([state isEqualToString:@"posttake"]) {
        self.btnCancel.hidden = NO;
        self.imageView.hidden = NO;
        self.btnUpload.hidden = NO;
        self.btnTakePhoto.hidden = YES;
        self.btnSwitchCamera.hidden = YES;
        self.btnMenu.hidden = YES;
        self.btnFlashOff.hidden = YES;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
