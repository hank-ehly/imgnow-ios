//
//  LoginViewController.m
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/21.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "LoginViewController.h"
#import "NSUserDefaults+Session.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blur-bg-portrait.jpg"]];
}

- (void)didReceiveMemoryWarning {[super didReceiveMemoryWarning];}

- (IBAction)touchedLogin:(id)sender {
    [self attemptLogin];
}

- (void)attemptLogin {
    
    NSString *routesFile = [[NSBundle mainBundle] pathForResource:@"api-routes" ofType:@"plist"];
    NSDictionary *routes = [NSDictionary dictionaryWithContentsOfFile:routesFile];
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [routes objectForKey:@"base"], [routes objectForKey:@"user_session"]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *urlSession = [NSURLSession sharedSession];
    
    NSString *email = _emailTextField.text;
    NSString *password = _passwordTextField.text;
    
    NSDictionary *loginCredentials = @{@"user":@{@"email":email,@"password":password}};
    NSData *requestJsonData = [NSJSONSerialization dataWithJSONObject:loginCredentials options:0 error:nil];
    request.HTTPBody = requestJsonData;
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setTimeoutInterval:7];
    request.HTTPMethod = @"POST";
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error || data == nil) {
                [self displayLoginError:error];
            }
            
            NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
            long statusCode = [res statusCode];
            
            if (statusCode == 201 && data != nil) {
                NSData *responseJsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                [[NSUserDefaults sharedInstance] createUserSessionWith:responseJsonData andStatus:@"loggedin"];
                [self performSegueWithIdentifier:@"loggedIn" sender:nil];
            }
        });
        
        
    }];
    
    [dataTask resume];
}

- (void)displayLoginError:(NSError *)error {
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Connection error" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *retry = [UIAlertAction actionWithTitle:@"Don't give up!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self attemptLogin];
    }];
    [controller addAction:ok];
    [controller addAction:retry];
    [self presentViewController:controller animated:YES completion:nil];
    
}


- (IBAction)segueToRegistration:(id)sender {
    [self performSegueWithIdentifier:@"toRegistration" sender:nil];
}

@end
