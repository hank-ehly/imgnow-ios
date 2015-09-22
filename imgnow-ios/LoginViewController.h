//
//  LoginViewController.h
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/21.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginViewControllerDelegate;

@interface LoginViewController : UIViewController

@property (weak, nonatomic) id <LoginViewControllerDelegate> delegate;

@end

@protocol LoginViewControllerDelegate <NSObject>

// methods

@end
