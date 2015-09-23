//
//  ImageDetailViewController.m
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/21.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "ImageDetailViewController.h"
#import "ImageTopViewController.h"

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
- (IBAction)goBack:(id)sender {[self dismissViewControllerAnimated:YES completion:nil];}


- (IBAction)handleSendEmailTouch:(id)sender {
    
    alertController = [UIAlertController alertControllerWithTitle:@"We emailed you at:" message:@"foobar@email.com" preferredStyle:UIAlertControllerStyleAlert];
    
    actionEmailOk = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // sent email
    }];
    
    [alertController addAction:actionEmailOk];
    
    [self presentViewController:alertController animated:YES completion:^{
        // presented view controller
    }];
    
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
        
        [self dismissViewControllerAnimated:YES completion:^{
            // dismissed
        }];
        
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
        NSData *responseJsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
//        long statusCode = [res statusCode];
        
        if (error) {
            NSLog(@"%@", error);
        }
        
//        NSLog(@"%@", responseJsonData);
//        NSLog(@"%lu", statusCode);
        
        [_delegate removeDeletedImage:[responseJsonData valueForKey:@"destroyed_image"]];
                
    }];
    
    [dataTask resume];
    
}


@end
