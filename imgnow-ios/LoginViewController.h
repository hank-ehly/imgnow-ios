//
//  LoginViewController.h
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/21.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

// This is the touch handler for the "Registration" button.
// It segues to the registration view
- (IBAction)segueToRegistration:(id)sender;

// This method sends a login request to the API
// and calls the appropriate completion handler
// based on the HTTP response
- (void)attemptLogin;

// This is the touch handler for the "Login" button
- (IBAction)handleTouchUpInsideLogin:(id)sender;

// Callback method for generic error upon attemptLogin failure
- (void) userSessionError:(NSError*)error;

// alert controller for LoginViewController
@property UIAlertController* alertController;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
