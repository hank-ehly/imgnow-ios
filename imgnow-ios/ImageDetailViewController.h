//
//  ImageDetailViewController.h
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/21.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)goBack:(id)sender;
- (IBAction)handleSendEmailTouch:(id)sender;
- (IBAction)handleExtendDeletionDateTouch:(id)sender;
- (IBAction)handleDeleteTouch:(id)sender;

@end
