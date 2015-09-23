//
//  SettingsTableViewController.h
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/21.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController

- (void) logoutUser;

@property (weak, nonatomic) IBOutlet UITableViewCell *passwordCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *emailCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *logoutCell;

@end
