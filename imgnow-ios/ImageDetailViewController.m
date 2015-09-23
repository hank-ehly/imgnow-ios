//
//  ImageDetailViewController.m
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/21.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "ImageDetailViewController.h"
#import "ImageTopViewController.h"
@import MessageUI;

@interface ImageDetailViewController ()

@end

@implementation ImageDetailViewController

@synthesize alertController;
@synthesize actionEmailOk;
@synthesize actionDownloadOk;
@synthesize actionExtendOk;
@synthesize actionDelete;
@synthesize actionCancelDelete;

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    // set bg-image
    NSString *routesFile = [[NSBundle mainBundle] pathForResource:@"api-routes" ofType:@"plist"];
    NSDictionary *routes = [NSDictionary dictionaryWithContentsOfFile:routesFile];
    NSString *url = [NSString stringWithFormat:@"%@%@", [routes objectForKey:@"base"], [_imageObject objectForKey:@"url"]];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    _imageView.image = [UIImage imageWithData:data];
    
    // set <img> label
    NSString *beg = @"<img src=\"";
    NSString *end = @"\"></img>";
    _imgSrcLabel.text = [NSString stringWithFormat:@"%@%@%@", beg, url, end];
    
}

- (void)didReceiveMemoryWarning {[super didReceiveMemoryWarning];}

- (IBAction)goBack:(id)sender {
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:transition forKey:nil];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}


- (IBAction)handleSendEmailTouch:(id)sender {
    
    [self sendEmail:_imgSrcLabel.text];
    
}


- (void)sendEmail:(NSString *)message {
    
    
    MFMailComposeViewController *mfvc = [[MFMailComposeViewController alloc] init];
    [mfvc setMailComposeDelegate:self];
    [mfvc setToRecipients:[NSArray arrayWithObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"user_email"]]];
    [mfvc setSubject:@"Your placeholder <img> tag"];
    [mfvc setMessageBody:message isHTML:NO];
    
    if ([MFMailComposeViewController canSendMail]) {
        [self presentViewController:mfvc animated:YES completion:nil];
    } else {
        NSString *title = @"Could Not Send Email";
        NSString *message = @"Your device could not send e-mail. Please check your e-mail configuration and try again";
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *aok = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // pressed ok
        }];
        [alertController addAction:aok];
        [self presentViewController:ac animated:YES completion:^{
            // showed email sent alert
        }];
    }
    
    
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}












- (IBAction)handleExtendDeletionDateTouch:(id)sender {
    
    NSString *msg = @"30 days from now -- Oct. 19, 2015";
    
    alertController = [UIAlertController alertControllerWithTitle:@"Deletion date moved to:" message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    actionExtendOk = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // said ok
    }];
    
    [alertController addAction:actionExtendOk];
    
    [self presentViewController:alertController animated:YES completion:^{
        // presented view controller
    }];
    
}

- (IBAction)handleDeleteTouch:(id)sender {
    
    alertController = [UIAlertController alertControllerWithTitle:@"Delete this photo" message:@"you sure?" preferredStyle:UIAlertControllerStyleAlert];
    
    actionCancelDelete = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // did cancel
    }];
    actionDelete = [UIAlertAction actionWithTitle:@"yea" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // did delete
        
        [self deleteImage];
        
        CATransition *transition = [CATransition animation];
        transition.duration = 0.3;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromLeft;
        [self.view.window.layer addAnimation:transition forKey:nil];
        [self dismissViewControllerAnimated:NO completion:nil];
        
    }];
    
    [alertController addAction:actionCancelDelete];
    [alertController addAction:actionDelete];
    
    [self presentViewController:alertController animated:YES completion:^{
        // presented view controller
    }];
    
}

- (IBAction)handleDownloadTouch:(id)sender {
    
    alertController = [UIAlertController alertControllerWithTitle:nil message:@"Downloaded to CameraRoll" preferredStyle:UIAlertControllerStyleAlert];
    
    actionDownloadOk = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // did press ok
    }];
    
    [alertController addAction:actionDownloadOk];
    
    [self presentViewController:alertController animated:YES completion:^{
        // presented view controller
    }];
    
}

- (void) deleteImage {
    
    NSString *routesFile = [[NSBundle mainBundle] pathForResource:@"api-routes" ofType:@"plist"];
    NSDictionary *routes = [NSDictionary dictionaryWithContentsOfFile:routesFile];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@.json", [routes objectForKey:@"base"], [routes objectForKey:@"api_image_delete"], [_imageObject objectForKey:@"image_id"]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *urlSession = [NSURLSession sharedSession];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    request.HTTPMethod = @"DELETE";
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSData *responseJsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (error) { NSLog(@"%@", error); }
            [_delegate removeDeletedImage:[responseJsonData valueForKey:@"destroyed_image"]];
        });
        
    }];
    
    [dataTask resume];
    
}


@end
