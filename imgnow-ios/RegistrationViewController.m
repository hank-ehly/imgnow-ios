//
//  RegistrationViewController.m
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/23.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "RegistrationViewController.h"
#import "NSUserDefaults+Session.h"
#import "Api.h"

@interface RegistrationViewController ()

@end

@implementation RegistrationViewController

#pragma mark - View Load

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
  self.view.backgroundColor =
  [UIColor colorWithPatternImage:[UIImage imageNamed:@"blur-bg-portrait.jpg"]];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}


#pragma mark - API Registration Call

- (IBAction)submitRegistration:(id)sender {
  
  NSMutableURLRequest *request = [Api accessRequestForUser:_emailTextField.text
                                              identifiedBy:_passwordTextField.text
                     isRegisteringWithPasswordConfirmation:_confirmPasswordTextField.text];
  
  [Api fetchContentsOfRequest:request
                   completion:^(NSData *data, NSURLResponse *response, NSError *error) {
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                       
                       if (error) [self presentErrorResponseAlert:error];
                       
                       switch ([Api statusCodeForResponse:response]) {
                         case 201:
                           [self userRegistrationSuccess:data];
                           break;
                         default:
                           NSLog(@"Status code %ld wasn't accounted for in RegistrationViewController.m submitRegistration",
                                 [Api statusCodeForResponse:response]);
                           break;
                       }
                       
                     });
                     
                   }];
  
}

#pragma mark - Async Completion

- (void)userRegistrationSuccess:(NSData*)data {
  NSData *responseJsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  [[NSUserDefaults sharedInstance] createUserSessionWith:responseJsonData andStatus:@"registered"];
  [self performSegueWithIdentifier:@"registered" sender:nil];
}

- (void)presentErrorResponseAlert:(NSError*)error {
  
  NSString *msg = [[error localizedDescription] stringByAppendingString:@" Please try again."];
  
  UIAlertController *alertController =
  [UIAlertController alertControllerWithTitle:@"Whoops!"
                                      message:msg
                               preferredStyle:UIAlertControllerStyleAlert];
  
  UIAlertAction *ok = [UIAlertAction actionWithTitle:@"ok"
                                               style:UIAlertActionStyleDefault
                                             handler:nil];
  [alertController addAction:ok];
  
  [self presentViewController:alertController animated:YES completion:nil];
}


@end
