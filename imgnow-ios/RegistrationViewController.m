//
//  RegistrationViewController.m
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/23.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "RegistrationViewController.h"
#import "NSUserDefaults+Session.h"

@interface RegistrationViewController ()

@end

@implementation RegistrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blur-bg-portrait.jpg"]];
}

- (void)viewWillAppear:(BOOL)animated {
    // this must be here, or else ViewController -> viewWillAppear gets called! (weird..)
}

- (void)didReceiveMemoryWarning {[super didReceiveMemoryWarning];}

- (IBAction)submitRegistration:(id)sender {
    
    NSString *routesFile = [[NSBundle mainBundle] pathForResource:@"api-routes" ofType:@"plist"];
    NSDictionary *routes = [NSDictionary dictionaryWithContentsOfFile:routesFile];
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [routes objectForKey:@"base"], [routes objectForKey:@"user_registration"]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *urlSession = [NSURLSession sharedSession];
    
    NSDictionary *credentials = @{@"user":@{@"email":_emailTextField.text,@"password":_passwordTextField.text,@"password_confirmation":_confirmPasswordTextField.text}};
    NSData *requestJsonData = [NSJSONSerialization dataWithJSONObject:credentials options:0 error:nil];
    request.HTTPBody = requestJsonData;
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setTimeoutInterval:10];
    request.HTTPMethod = @"POST";
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
        long statusCode = [res statusCode];
        
        dispatch_async(dispatch_get_main_queue(), ^{

            if (error) {
                [self presentErrorResponseAlert:error];
            }
            
            NSLog(@"%lu", statusCode);
            
            if (statusCode == 201) {
                NSData *responseJsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                [[NSUserDefaults sharedInstance] createUserSessionWith:responseJsonData andStatus:@"registered"];
                [self performSegueWithIdentifier:@"registered" sender:nil];
            }
            
        });
        
    }];
    
    [dataTask resume];
    
}

- (void)presentErrorResponseAlert:(NSError*)error {
    
    NSString *msg = [[error localizedDescription] stringByAppendingString:@" Please try again."];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Whoops!" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
    
}


@end
