//
//  LoginViewController.m
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/21.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "LoginViewController.h"
#import "Api.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize alertController;

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
  
  NSMutableURLRequest *request = [Api sessionRequestForUser:_emailTextField.text
                                               identifiedBy:_passwordTextField.text
                      isRegisteringWithPasswordConfirmation:nil];
  
  [Api fetchContentsOfRequest:request
                   completion:^(NSData *data, NSURLResponse *response, NSError *error) {
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                       
                       [_activityIndicator stopAnimating];
                       
                       if (error) [self userSessionError:error];
                       
                       switch ([Api statusCodeForResponse:response]) {
                         case 201:
                           [self userSessionSuccess:data];
                           break;
                         case 401:
                           [self userSessionUnauthorized:data];
                           break;
                         default:
                           NSLog(@"Status code %ld isn't accounted for in LoginViewController",
                                 [Api statusCodeForResponse:response]);
                           break;
                       }
                       
                     });
                     
                   }];
  
}

#pragma mark - Async Callbacks

- (void) userSessionSuccess:(NSData*)data {
  
  // serialize login-success response to json
  NSData *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  
  // create session for current user
  [[NSUserDefaults standardUserDefaults] setObject:[jsonResponse valueForKey:@"email"]
                                            forKey:@"user_email"];
  
  // tell ViewController that we just logged in
  [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"status"];
  
  [self performSegueWithIdentifier:@"loggedIn" sender:nil];
  
}

- (void) userSessionUnauthorized:(NSData*)data {
  
  // alert controller text configuration
  NSString *message = NSLocalizedStringFromTable(@"invalidCredentials", @"AlertStrings", nil);
  NSString *alertTitle = NSLocalizedStringFromTable(@"defaultFailureTitle", @"AlertStrings", nil);
  NSString *acceptTitle = NSLocalizedStringFromTable(@"defaultAcceptTitle", @"AlertStrings", nil);
  
  // alert controller config
  alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                        message:message
                                                 preferredStyle:UIAlertControllerStyleAlert];
  
  // alert controller "accept" action
  UIAlertAction *actionAccept = [UIAlertAction actionWithTitle:acceptTitle
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil];
  
  [alertController addAction:actionAccept];
  
  [self presentViewController:alertController animated:YES completion:nil];
  
}

- (void)userSessionError:(NSError *)error {
  
  [_activityIndicator stopAnimating];
  
  // configure alert controller strings
  NSString *alertTitle = NSLocalizedStringFromTable(@"defaultFailureTitle", @"AlertStrings", nil);
  NSString *acceptTitle = NSLocalizedStringFromTable(@"defaultAcceptTitle", @"AlertStrings", nil);
  NSString *retryTitle = NSLocalizedStringFromTable(@"defaultRetryTitle", @"AlertStrings", nil);
  
  // configure alert controller
  alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                        message:[error localizedDescription]
                                                 preferredStyle:UIAlertControllerStyleAlert];
  
  // alert controller accept action
  UIAlertAction *actionAccept = [UIAlertAction actionWithTitle:acceptTitle
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil];
  
  // alert controller retry login action
  UIAlertAction *actionRetry = [UIAlertAction actionWithTitle:retryTitle
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                        
                                                        [_activityIndicator startAnimating];
                                                        [self attemptLogin];
                                                        
                                                      }];
  // add actions to alert controller
  [alertController addAction:actionAccept];
  [alertController addAction:actionRetry];
  
  [self presentViewController:alertController animated:YES completion:nil];
  
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
