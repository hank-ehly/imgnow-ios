//
//  SettingsTableViewController.m
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/21.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "Api.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  _emailCell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"user_email"];
  
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
  
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  if ([[[selectedCell textLabel] text] isEqualToString:@"logout"] && indexPath.row == 2) {
    
    [self confirmLogout];
    
  }
  
}

- (void) confirmLogout {
  
  
  UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:@"Are you sure you wanna logout?" preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *yes = [UIAlertAction actionWithTitle:@"yeah" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    [self logoutUser];
  }];
  UIAlertAction *no = [UIAlertAction actionWithTitle:@"no" style:UIAlertActionStyleCancel handler:nil];
  
  [ac addAction:yes];
  [ac addAction:no];
  [self presentViewController:ac animated:YES completion:nil];
  
}

- (void)logoutUser {
  
  NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_email"];
  NSMutableURLRequest *request = [Api sessionRequestForUser:uid
                                               identifiedBy:nil
                      isRegisteringWithPasswordConfirmation:nil];
  
  [Api fetchContentsOfRequest:request
                   completion:^(NSData *data, NSURLResponse *response, NSError *error) {
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                       
                       if (error) {
                         // handle error
                       }
                       
                       switch ([Api statusCodeForResponse:response]) {
                         case 200:
                           [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_email"];
                           [self performSegueWithIdentifier:@"logout" sender:nil];
                           break;
                         default:
                           NSLog(@"Status code %ld wasn't accounted for in SettingsTableViewController logoutUser",
                                 [Api statusCodeForResponse:response]);
                           break;
                       }

                     });
                   }];
  
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 3;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 64.0f;
}

@end
