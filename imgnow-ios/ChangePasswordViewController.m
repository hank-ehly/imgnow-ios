//
//  ChangePasswordViewController.m
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/10/06.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "Api.h"

@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController

@synthesize alertController;

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (IBAction)handleTouchBack:(id)sender {
  [self performSegueWithIdentifier:@"returnToSettings" sender:nil];
}

- (IBAction)handleTouchSave:(id)sender {
  [self attemptChangePassword];
}

- (void)attemptChangePassword {
  
  NSMutableURLRequest *request;
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  request = [Api changePasswordRequestForUser:[defaults valueForKey:@"user_email"]
                                 identifiedBy:_oldPasswordTextField.text
                              withNewPassword:_passwordNewTextField.text
                                confirmedWith:_confirmNewPasswordTextField.text];
  
  [Api fetchContentsOfRequest:request
                   completion:
   
   ^(NSData *data, NSURLResponse *response, NSError *error) {
     
     dispatch_async(dispatch_get_main_queue(), ^{
       
       if (error) {
         [self asyncError:error];
         return;
       }
       
       switch ([Api statusCodeForResponse:response]) {
         case 200:
           [self changePasswordCallback:data];
           break;
         default:
           NSLog(@"Status code %ld wasn't accounted for in ChangePasswordViewController attemptChangePassword",
                 [Api statusCodeForResponse:response]);
           break;
       }
       
     });
     
   }];
  
}

- (void)changePasswordCallback:(NSData*)data {
  
  if (!data) return;
  
  NSData *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  
  if ([json valueForKey:@"errors"]) {
    // has errors
    
    NSLog(@"%@", [json valueForKey:@"errors"]);
    
    NSString *msg = [[NSString alloc] init];
    
    for (NSString *errorMsg in [json valueForKey:@"errors"]) {
      msg = [msg stringByAppendingString:[NSString stringWithFormat:@"• %@.\n", errorMsg]];
    }
    
    // configure alert controller strings
    NSString *alertTitle = NSLocalizedStringFromTable(@"defaultFailureTitle", @"AlertStrings", nil);
    NSString *alertMessage = msg;
    NSString *acceptTitle = NSLocalizedStringFromTable(@"defaultAcceptTitle", @"AlertStrings", nil);
    
    alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                          message:alertMessage
                                                   preferredStyle:UIAlertControllerStyleAlert];
    
    // accept action returns to settings view
    UIAlertAction *actionAccept = [UIAlertAction actionWithTitle:acceptTitle
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
    
    [alertController addAction:actionAccept];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
  } else {
    
    // configure alert controller strings
    NSString *alertTitle = NSLocalizedStringFromTable(@"changePasswordSuccessTitle", @"AlertStrings", nil);
    NSString *alertMessage = NSLocalizedStringFromTable(@"changePasswordSuccessMsg", @"AlertStrings", nil);
    NSString *acceptTitle = NSLocalizedStringFromTable(@"defaultAcceptTitle", @"AlertStrings", nil);
    
    alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                          message:alertMessage
                                                   preferredStyle:UIAlertControllerStyleAlert];
    
    // accept action returns to settings view
    UIAlertAction *actionAccept = [UIAlertAction actionWithTitle:acceptTitle
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                           
                                                           [self performSegueWithIdentifier:@"returnToSettings"
                                                                                     sender:nil];
                                                         }];
    
    [alertController addAction:actionAccept];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
  }
  
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
