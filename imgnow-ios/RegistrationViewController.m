//
//  RegistrationViewController.m
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/23.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "RegistrationViewController.h"
#import "Api.h"

@interface RegistrationViewController ()

@end

@implementation RegistrationViewController

@synthesize alertController;

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
  
  NSMutableURLRequest *request = [Api sessionRequestForUser:_emailTextField.text
                                               identifiedBy:_passwordTextField.text
                      isRegisteringWithPasswordConfirmation:_confirmPasswordTextField.text];
  
  [Api fetchContentsOfRequest:request
                   completion:^(NSData *data, NSURLResponse *response, NSError *error) {
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                       
                       if (error) [self userRegistrationError:error];
                       
                       switch ([Api statusCodeForResponse:response]) {
                         case 201:
                           [self userRegistrationSuccess:data];
                           break;
                         default:
                           NSLog(@"Status code %ld wasn't accounted for in RegistrationViewController",
                                 [Api statusCodeForResponse:response]);
                           break;
                       }
                       
                     });
                     
                   }];
  
}

#pragma mark - Async Callbacks

- (void)userRegistrationSuccess:(NSData*)data {
  
  NSData *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  
  [[NSUserDefaults standardUserDefaults] setObject:[jsonResponse valueForKey:@"email"]
                                            forKey:@"user_email"];
  
  [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:@"status"];
  
  [self performSegueWithIdentifier:@"registered" sender:nil];
  
}

- (void)userRegistrationError:(NSError*)error {

  NSString *alertTitle = NSLocalizedStringFromTable(@"defaultFailureTitle", @"AlertStrings", nil);
  NSString *acceptTitle = NSLocalizedStringFromTable(@"defaultAcceptTitle", @"AlertStrings", nil);
  
  alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                        message:[error localizedDescription]
                                                 preferredStyle:UIAlertControllerStyleAlert];
  
  UIAlertAction *accept = [UIAlertAction actionWithTitle:acceptTitle
                                               style:UIAlertActionStyleDefault
                                             handler:nil];

  [alertController addAction:accept];
  
  [self presentViewController:alertController animated:YES completion:nil];
  
}


@end
