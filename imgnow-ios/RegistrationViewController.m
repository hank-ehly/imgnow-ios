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

// This allows the the user to get rid of the keyboard by
// touching another part of the screen after editing a text field
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [[self view] endEditing:YES];
}

#pragma mark - API Registration Call

- (IBAction)attemptRegistration:(id)sender {
  
  NSMutableURLRequest *request = [Api sessionRequestForUser:_emailTextField.text
                                               identifiedBy:_passwordTextField.text
                      isRegisteringWithPasswordConfirmation:_confirmPasswordTextField.text];
  
  [Api fetchContentsOfRequest:request
                   completion:
   
   ^(NSData *data, NSURLResponse *response, NSError *error) {
     
     dispatch_async(dispatch_get_main_queue(), ^{
       
       if (error) {
         [self asyncError:error];
         return;
       }
       
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
  
  // serialize successful registration response into json
  NSData *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  
  // create currentuser session
  [[NSUserDefaults standardUserDefaults] setObject:[jsonResponse valueForKey:@"email"]
                                            forKey:@"user_email"];
  
  // tell ViewController that we just registered
  [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:@"status"];
  
  [self performSegueWithIdentifier:@"registered" sender:nil];
  
}

- (void)asyncError:(NSError*)error {
  
  // configure alert controller strings
  NSString *alertTitle = NSLocalizedStringFromTable(@"defaultFailureTitle", @"AlertStrings", nil);
  NSString *acceptTitle = NSLocalizedStringFromTable(@"defaultAcceptTitle", @"AlertStrings", nil);
  NSString *alertMessage = [error localizedDescription];
  
  
  // configure alert controller
  alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                        message:alertMessage
                                                 preferredStyle:UIAlertControllerStyleAlert];
  
  // accept action
  UIAlertAction *actionAccept = [UIAlertAction actionWithTitle:acceptTitle
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil];
  
  [alertController addAction:actionAccept];
  
  [self presentViewController:alertController animated:YES completion:nil];
  
}


@end
