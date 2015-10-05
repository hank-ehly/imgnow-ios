//
//  ChangePasswordViewController.h
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/10/06.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePasswordViewController : UIViewController

- (IBAction)handleTouchBack:(id)sender;
- (IBAction)handleTouchSave:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordNewTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmNewPasswordTextField;

@end
