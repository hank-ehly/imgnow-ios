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

#pragma mark - View Load

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor =
  [UIColor colorWithPatternImage:[UIImage imageNamed:@"blur-bg-portrait.jpg"]];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - API Login Call

- (IBAction)handleTouchUpInsideLogin:(id)sender {
  [self attemptLogin];
}

- (void)attemptLogin {
  
  [_activityIndicator startAnimating];
  
  NSMutableURLRequest *request = [Api accessRequestForUser:_emailTextField.text
                                              identifiedBy:_passwordTextField.text
                     isRegisteringWithPasswordConfirmation:nil];
  
  [Api fetchContentsOfRequest:request
                   completion:^(NSData *data, NSURLResponse *response, NSError *error) {
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                       
                       if (error) [self displayLoginError:error];
                       
                       switch ([Api statusCodeForResponse:response]) {
                         case 201:
                           [self userSessionSuccess:data];
                           break;
                         case 401:
                           [self userSessionUnauthorized:data];
                           break;
                         default:
                           NSLog(@"%ld", [Api statusCodeForResponse:response]);
                           break;
                       }
                       
                     });
                     
                   }];
  
}

#pragma mark - Async Completion

- (void) userSessionSuccess:(NSData*)data {
  NSData *responseJsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  [[NSUserDefaults sharedInstance] createUserSessionWith:responseJsonData andStatus:@"loggedin"];
  [self performSegueWithIdentifier:@"loggedIn" sender:nil];
  [_activityIndicator stopAnimating];
}

- (void) userSessionUnauthorized:(NSData*)data {
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

#pragma mark - Navigation

- (IBAction)segueToRegistration:(id)sender {
  [self performSegueWithIdentifier:@"toRegistration" sender:nil];
}

#pragma mark - Other

// This allows the the user to get rid of the keyboard by
// touching another part of the screen after editing a text field
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [self.view endEditing:YES];
}

@end
