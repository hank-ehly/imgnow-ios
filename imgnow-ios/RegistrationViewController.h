//
//  RegistrationViewController.h
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/23.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "ViewController.h"

@interface RegistrationViewController : ViewController

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property UIAlertController *alertController;

- (IBAction)attemptRegistration:(id)sender;
- (void) userRegistrationError:(NSError*)error;

@end
