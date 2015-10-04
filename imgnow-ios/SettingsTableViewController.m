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

@synthesize alertController;

#pragma mark - View Load

- (void)viewDidLoad {
  [super viewDidLoad];
    _emailCell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"user_email"];
}

- (void)viewDidAppear:(BOOL)animated {

}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - Table View

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  // this is the cell that was touched
  UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
  
  // deselect cells automatically so the don't stay highlighted
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  // prompt the user if they touched 'logout'
  if ([[[selectedCell textLabel] text] isEqualToString:@"logout"] && indexPath.row == 2) {
    [self confirmLogout];
  }
  
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 64.0f;
}

- (void) confirmLogout {
  
  // configure alert controller strings
  NSString *alertTitle = NSLocalizedStringFromTable(@"logoutTitle", @"AlertStrings", nil);
  NSString *alertMessage = NSLocalizedStringFromTable(@"confirmLogout", @"AlertStrings", nil);
  NSString *acceptTitle = NSLocalizedStringFromTable(@"defaultAcceptTitle", @"AlertStrings", nil);
  
  // configure alert controller
  alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                        message:alertMessage
                                                 preferredStyle:UIAlertControllerStyleAlert];
  
  // accept action logout user
  UIAlertAction *actionAccept = [UIAlertAction actionWithTitle:acceptTitle
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                         [self logoutUser];
                                                       }];
  // cancel action
  UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];
  // add actions and present alert controller
  [alertController addAction:actionAccept];
  [alertController addAction:actionCancel];
  [self presentViewController:alertController animated:YES completion:nil];
  
}

#pragma mark - Api Calls

- (void)logoutUser {
  
  NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_email"];
  NSMutableURLRequest *request = [Api sessionRequestForUser:uid
                                               identifiedBy:nil
                      isRegisteringWithPasswordConfirmation:nil];
  
  [Api fetchContentsOfRequest:request
                   completion:
   
   ^(NSData *data, NSURLResponse *response, NSError *error) {
     
     dispatch_async(dispatch_get_main_queue(), ^{
       
       if (error) {
         [self asyncError:error];
         return;
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

#pragma mark - Api Callbacks

- (void)asyncError:(NSError*)error {
  
  // configure alert controller strings
  NSString *alertTitle = NSLocalizedStringFromTable(@"defaultFailureTitle", @"AlertStrings", nil);
  NSString *acceptTitle = NSLocalizedStringFromTable(@"defaultAcceptTitle", @"AlertStrings", nil);
  NSString *alertMessage = [error localizedDescription];
  
  // configure alert controller
  alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                        message:alertMessage
                                                 preferredStyle:UIAlertControllerStyleAlert];
  
  // configure alert controller accept action
  UIAlertAction *actionAccept = [UIAlertAction actionWithTitle:acceptTitle
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil];
  
  [alertController addAction:actionAccept];
  
  [self presentViewController:alertController animated:YES completion:nil];
  
}

@end
