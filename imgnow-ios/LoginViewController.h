//
//  LoginViewController.h
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/21.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

- (IBAction)touchedLogin:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
- (IBAction)segueToRegistration:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


- (void) displayLoginError:(NSError*)error;
- (void) attemptLogin;

@end
