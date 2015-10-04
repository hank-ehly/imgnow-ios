//
//  ImageTopViewController.h
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/21.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageDetailViewController.h"

@interface ImageTopViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ImageDetailViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property UIRefreshControl *refreshControl;
@property NSMutableArray *images;
@property UIAlertController *alertController;

- (IBAction)returnToCameraView:(id)sender;
- (void) queryForImages;

@end
