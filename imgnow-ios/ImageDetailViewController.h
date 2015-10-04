//
//  ImageDetailViewController.h
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/21.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MessageUI;

@protocol ImageDetailViewControllerDelegate;

@interface ImageDetailViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UINavigationItem *navTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *imgSrcLabel;
@property (weak, nonatomic) IBOutlet UILabel *deletionDateLabel;
@property (weak, nonatomic) id <ImageDetailViewControllerDelegate> delegate;
@property NSDictionary *imageObject;
@property UIAlertController *alertController;

- (IBAction)returnToImageTop:(id)sender;
- (IBAction)handleSendEmailTouch:(id)sender;
- (IBAction)handleExtendDeletionDateTouch:(id)sender;
- (IBAction)handleDeleteTouch:(id)sender;
- (IBAction)handleDownloadTouch:(id)sender;
- (void)sendEmail:(NSString *)message;
- (void)extendDeletionDateOfImage:(NSString*)id;

@end

@protocol ImageDetailViewControllerDelegate <NSObject>
- (void) removeDeletedImage:(NSDictionary *)imageObject;
@end