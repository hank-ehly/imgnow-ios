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

// delegate
@property (weak, nonatomic) id <ImageDetailViewControllerDelegate> delegate;

- (IBAction)goBack:(id)sender;
- (IBAction)handleSendEmailTouch:(id)sender;
- (IBAction)handleExtendDeletionDateTouch:(id)sender;
- (IBAction)handleDeleteTouch:(id)sender;

@property (weak, nonatomic) IBOutlet UINavigationItem *navTitle;

@end


@protocol ImageDetailViewControllerDelegate <NSObject>
// - (void) imageDetailViewControllerDidPressBack;
@end