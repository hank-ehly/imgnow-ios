//
//  ImageDetailViewController.h
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/21.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageDetailViewControllerDelegate;

@interface ImageDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *imgSrcLabel;
@property NSString *image_url;

// delegate
@property (weak, nonatomic) id <ImageDetailViewControllerDelegate> delegate;

@property UIAlertController *alertController;
@property UIAlertAction *actionEmailOk;
@property UIAlertAction *actionDownloadOk;
@property UIAlertAction *actionExtendOk;
@property UIAlertAction *actionDelete;
@property UIAlertAction *actionCancelDelete;

- (IBAction)goBack:(id)sender;
- (IBAction)handleSendEmailTouch:(id)sender;
- (IBAction)handleExtendDeletionDateTouch:(id)sender;
- (IBAction)handleDeleteTouch:(id)sender;
- (IBAction)handleDownloadTouch:(id)sender;

@property (weak, nonatomic) IBOutlet UINavigationItem *navTitle;

@end

@protocol ImageDetailViewControllerDelegate <NSObject>
// - (void) imageDetailViewControllerDidPressBack;
@end