//
//  LoginViewController.m
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/21.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "LoginViewController.h"
#import "NSUserDefaults+Session.h"
#import "Api.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blur-bg-portrait.jpg"]];
}

- (void)didReceiveMemoryWarning {[super didReceiveMemoryWarning];}

- (void)attemptLogin {
    
  [_activityIndicator startAnimating];
  
  NSURL *url = [Api fetchUrlForApiNamedRoute:@"user_session" withResourceId:nil];
  
  NSMutableURLRequest *request = [Api loginRequestForUser:_emailTextField.text
                                             identifiedBy:_passwordTextField.text];
  
  [Api fetchContentsOfRequest:request completion:^(NSData *data, NSError *error) {
    
  }];
  
  NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
      
      dispatch_async(dispatch_get_main_queue(), ^{
          if (error || data == nil) {
              [self displayLoginError:error];
          }
          
          NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
          long statusCode = [res statusCode];
          
          switch (statusCode) {
              case 201:
                  [self sessionCreatedSuccessfully:data];
                  break;
              case 401:
                  [self sessionCreationUnauthorized:data];
                  break;
              default:
                  break;
          }
          
      });
      
      
  }];
  
  [dataTask resume];
}

- (IBAction)handleTouchUpInsideLogin:(id)sender {
  [self attemptLogin];
}

- (void) sessionCreatedSuccessfully:(NSData*)data {
    NSData *responseJsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    [[NSUserDefaults sharedInstance] createUserSessionWith:responseJsonData andStatus:@"loggedin"];
    [self performSegueWithIdentifier:@"loggedIn" sender:nil];
    [_activityIndicator stopAnimating];
}
- (void) sessionCreationUnauthorized:(NSData*)data {
    NSString *msg = @"Email and/or password is incorrect. Please try again.";
    UIAlertController *c = [UIAlertController alertControllerWithTitle:@"Whoops!" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *a = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
    [c addAction:a];
    [_activityIndicator stopAnimating];
    [self presentViewController:c animated:YES completion:nil];
}

- (void)displayLoginError:(NSError *)error {
        [_activityIndicator stopAnimating];
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Connection error" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *retry = [UIAlertAction actionWithTitle:@"Don't give up!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [_activityIndicator startAnimating];
        [self attemptLogin];
    }];
    [controller addAction:ok];
    [controller addAction:retry];
    [self presentViewController:controller animated:YES completion:nil];
    
}

- (IBAction)segueToRegistration:(id)sender {
    [self performSegueWithIdentifier:@"toRegistration" sender:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
