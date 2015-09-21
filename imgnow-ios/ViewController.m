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

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    
//    [self changeWindowState:@"pretake"];
    
    captureSession = [[AVCaptureSession alloc] init];
    captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    NSError *error = nil;
    AVCaptureDevice *captureDevise = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *captureDeviseInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevise error:&error];

    if ([captureSession canAddInput:captureDeviseInput]) {
        [captureSession addInput:captureDeviseInput];
    }
    
//    [captureSession canAddInput:captureDeviseInput] ? [captureSession addInput:captureDeviseInput] : NULL;
    
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    CGRect bounds = self.view.layer.bounds;
    previewLayer.bounds = bounds;
    previewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    [self.view.layer insertSublayer:previewLayer atIndex:0];
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *stillImageOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    stillImageOutput.outputSettings = stillImageOutputSettings;
    
    [captureSession addOutput:stillImageOutput];
    
//    [captureSession canAddOutput:stillImageOutput] ? [captureSession addOutput:stillImageOutput] : NULL;
    
    [captureSession startRunning];
    
}

- (IBAction)takePhoto:(id)sender {
}

- (IBAction)cancel:(id)sender {
}

- (IBAction)switchCamera:(id)sender {
}

- (IBAction)goToImageList:(id)sender {
}

- (IBAction)flashOff:(id)sender {
}

-(void)changeWindowState:(NSString *)state {
    
    if ([state isEqualToString:@"pretake"]) {
        self.btnCancel.hidden = YES;
        self.imageView.hidden = YES;
        self.btnTakePhoto.hidden = NO;
        self.btnSwitchCamera.hidden = NO;
        self.btnMenu.hidden = NO;
        self.btnFlashOff.hidden = NO;
    } else if ([state isEqualToString:@"posttake"]) {
        self.btnCancel.hidden = NO;
        self.imageView.hidden = NO;
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
