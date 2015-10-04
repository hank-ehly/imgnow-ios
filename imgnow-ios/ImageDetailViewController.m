//
//  ImageDetailViewController.m
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/21.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "ImageDetailViewController.h"
#import "ImageTopViewController.h"
#import "Api.h"
@import MessageUI;

@interface ImageDetailViewController ()

@end

@implementation ImageDetailViewController

@synthesize alertController;

#pragma mark - View Load

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
  
  // set the image for the imageView
  NSString *routesFile = [[NSBundle mainBundle] pathForResource:@"api-routes" ofType:@"plist"];
  NSDictionary *routes = [NSDictionary dictionaryWithContentsOfFile:routesFile];
  NSString *url = [NSString stringWithFormat:@"%@%@", [routes objectForKey:@"base"], [_imageObject objectForKey:@"url"]];
  NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
  _imageView.image = [UIImage imageWithData:data];
  
  // set the img tag text
  [_imgSrcLabel setText:[Api imgTagWithSrc:url]];
  
  [self updateViewWithTimeUntilDeletion];
  
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - Api Calls

- (void)extendDeletionDateOfImage:(NSString *)id {
  
  NSMutableURLRequest *request = [Api imageUpdateRequest:id];
  
  [Api fetchContentsOfRequest:request
                   completion:
   
   ^(NSData *data, NSURLResponse *response, NSError *error) {
     
     dispatch_async(dispatch_get_main_queue(), ^{
       
       if (error) [self asyncError:error];
       
       switch([Api statusCodeForResponse:response]) {
         case 200:
           [self imageUpdateSuccess:data];
           break;
         default:
           NSLog(@"Status code %ld wasn't accounted for in ImageDetailViewController.m extendDeletionDateOfImage",
                 [Api statusCodeForResponse:response]);
           break;
       }
       
     });
     
   }];
  
}

- (void)deleteImage {
  
  NSMutableURLRequest *request = [Api imageDeleteRequest:[_imageObject objectForKey:@"image_id"]];
  
  [Api fetchContentsOfRequest:request
                   completion:
   
   ^(NSData *data, NSURLResponse *response, NSError *error) {
     
     dispatch_async(dispatch_get_main_queue(), ^{
       
       if (error) [self asyncError:error];
       
       switch ([Api statusCodeForResponse:response]) {
         case 200:
           [self imageDeleteSuccess:data];
           break;
         default:
           NSLog(@"Status code %ld wasn't accounted for in ImageDetailViewController.m deleteImage",
                 [Api statusCodeForResponse:response]);
           break;
       }
       
     });
     
   }];
  
}

#pragma mark - Async Handlers

- (void)imageUpdateSuccess:(NSData*)data {
  
  // serialize success response into json
  NSData *responseJsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  
  // if "success" is true, then we are able to grant 30 more days
  // because the time_until_deletion has not previously been set
  BOOL deletionDateExtendable = [[responseJsonData valueForKey:@"success"] intValue] == 1 ? YES : NO;
  
  // configure alert defaults
  NSString *alertTitle = NSLocalizedStringFromTable(@"deletionDateExtendable", @"AlertStrings", nil);
  NSString *alertMessage = NSLocalizedStringFromTable(@"extendDeletionMessage", @"AlertStrings", nil);
  NSString *acceptTitle = NSLocalizedStringFromTable(@"defaultAcceptTitle", @"AlertStrings", nil);
  UIAlertAction *actionAccept = [[UIAlertAction alloc] init];
  
  if (deletionDateExtendable) {
    
    // accept action that updates view with new deletion date
    actionAccept =
    [UIAlertAction actionWithTitle:acceptTitle
                             style:UIAlertActionStyleDefault
                           handler:
     
     ^(UIAlertAction * _Nonnull action) {

       float time = [[[responseJsonData valueForKey:@"image"] valueForKey:@"time_until_deletion"] floatValue];
       int timeUntilDeletion = (int)ceilf(time);
       NSDictionary *dict = [Api timeUntilDeletion:timeUntilDeletion];
       NSString *amount = [dict valueForKey:@"time"];
       NSString *counter = [dict valueForKey:@"counter"];
       _deletionDateLabel.text = [NSString stringWithFormat:@"Scheduled for deletion in %@ %@", amount, counter];
       
     }];
    
  } else {
    
    alertMessage = NSLocalizedStringFromTable(@"deletionDateFixed", @"AlertStrings", nil);
    alertTitle = NSLocalizedStringFromTable(@"defaultFailureTitle", @"AlertStrings", nil);
    
    // accept action that does nothing
    actionAccept = [UIAlertAction actionWithTitle:acceptTitle
                                            style:UIAlertActionStyleDefault
                                          handler:nil];
  }
  
  // configure alert controller with above preferences
  alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                        message:alertMessage
                                                 preferredStyle:UIAlertControllerStyleAlert];
  
  // add dynamically generated accept action
  [alertController addAction:actionAccept];
  
  // present the alert
  [self presentViewController:alertController animated:YES completion:nil];
  
}

- (void) updateViewWithTimeUntilDeletion {
  NSDictionary *timeUntilDeletionObject = [_imageObject valueForKey:@"timeUntilDeletionObject"];
  NSString *amountOfTime = [timeUntilDeletionObject valueForKey:@"time"];
  NSString *counter = [timeUntilDeletionObject valueForKey:@"counter"];
  _deletionDateLabel.text = [NSString stringWithFormat:@"Scheduled for deletion in %@ %@", amountOfTime, counter];
}

- (void)imageDeleteSuccess:(NSData*)data {
  
  // serialize success response to json
  NSData *responseJsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  
  // tell ImageTop to update its tableView
  [_delegate removeDeletedImage:[responseJsonData valueForKey:@"destroyed_image"]];
  
}

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

#pragma mark - Touch Handlers

- (IBAction)handleSendEmailTouch:(id)sender {
  [self sendEmail:_imgSrcLabel.text];
}

- (IBAction)handleExtendDeletionDateTouch:(id)sender {
  
  NSString *alertTitle = NSLocalizedStringFromTable(@"confirmExtendDeletion", @"AlertStrings", nil);
  NSString *alertMessage = NSLocalizedStringFromTable(@"warnExtendDeletion", @"AlertStrings", nil);
  NSString *acceptTitle = NSLocalizedStringFromTable(@"defaultAcceptTitle", @"AlertStrings", nil);
  
  alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                        message:alertMessage
                                                 preferredStyle:UIAlertControllerStyleAlert];
  
  // accept action with handler
  UIAlertAction *actionAccept =
  [UIAlertAction actionWithTitle:acceptTitle
                           style:UIAlertActionStyleDefault
                         handler:
   ^(UIAlertAction * _Nonnull action) {
     [self extendDeletionDateOfImage:[_imageObject valueForKey:@"image_id"]];
   }];
  
  // cancel action
  UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];
  
  // add actions to alert controller
  [alertController addAction:actionAccept];
  [alertController addAction:actionCancel];
  
  // present alert controller
  [self presentViewController:alertController animated:YES completion:nil];
  
}

- (IBAction)handleDeleteTouch:(id)sender {
  
  // configure alert controller strings
  NSString *alertTitle = NSLocalizedStringFromTable(@"deleteImageTitle", @"AlertStrings", nil);
  NSString *alertMessage = NSLocalizedStringFromTable(@"deleteImageConfirmation", @"AlertStrings", nil);
  NSString *acceptTitle = NSLocalizedStringFromTable(@"defaultAcceptTitle", @"AlertStrings", nil);
  
  // configure alert controller
  alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                        message:alertMessage
                                                 preferredStyle:UIAlertControllerStyleAlert];
  
  // accept action deletes the image
  UIAlertAction *actionAccept =
  [UIAlertAction actionWithTitle:acceptTitle
                           style:UIAlertActionStyleDestructive
                         handler:
   ^(UIAlertAction * _Nonnull action) {

     [self deleteImage];

     // return to ImageTop with sliding motion
     CATransition *transition = [CATransition animation];
     transition.duration = 0.3;
     transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
     transition.type = kCATransitionPush;
     transition.subtype = kCATransitionFromLeft;
     [self.view.window.layer addAnimation:transition forKey:nil];
     [self dismissViewControllerAnimated:NO completion:nil];
     
   }];
  
  // cancel action
  UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];
  
  // add actions to alert controller
  [alertController addAction:actionAccept];
  [alertController addAction:actionCancel];
  
  // present alert controller
  [self presentViewController:alertController animated:YES completion:nil];
  
}

- (IBAction)handleDownloadTouch:(id)sender {
  
  // get image from url and save it to camera roll
  NSString *url = [NSString stringWithFormat:@"%@%@", [Api fetchBaseRouteString], [_imageObject objectForKey:@"url"]];
  NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
  UIImage *image = [UIImage imageWithData:data];
  UIImageWriteToSavedPhotosAlbum(image, self, @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:withContextInfo:), NULL);
  
}

- (void)thisImage:(UIImage *)image
hasBeenSavedInPhotoAlbumWithError:(NSError *)error
  withContextInfo:(void*)contextInfo {

  NSString *alertTitle = nil;
  NSString *alertMessage = NSLocalizedStringFromTable(@"saveToCameraRollSuccess", @"AlertStrings", nil);
  NSString *acceptTitle = NSLocalizedStringFromTable(@"defaultAcceptTitle", @"AlertStrings", nil);

  if (error) {

    // configure alert controller strings when you couldn't save to camera roll
    alertTitle = NSLocalizedStringFromTable(@"defaultFailureTitle", @"AlertStrings", nil);
    alertMessage = NSLocalizedStringFromTable(@"saveToCameraRollFailure", @"AlertStrings", nil);

  }
  
  // configure alert controller
  alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                        message:alertMessage
                                                 preferredStyle:UIAlertControllerStyleAlert];
  
  // accept action
  UIAlertAction *actionAccept = [UIAlertAction actionWithTitle:acceptTitle
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil];
  
  [alertController addAction:actionAccept];
  
  [self presentViewController:alertController animated:YES completion:nil];
  
}

#pragma mark - Email

- (void)sendEmail:(NSString *)message {
  
  // configure the email view controller
  MFMailComposeViewController *mfvc = [[MFMailComposeViewController alloc] init];
  [mfvc setMailComposeDelegate:self];
  [mfvc setToRecipients:[NSArray arrayWithObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"user_email"]]];
  [mfvc setSubject:NSLocalizedStringFromTable(@"defaultEmailSubject", @"AlertStrings", nil)];
  [mfvc setMessageBody:message isHTML:NO];
  
  // open the mail controller if you can
  // otherwise, let the user know they can't
  if ([MFMailComposeViewController canSendMail]) {
    [self presentViewController:mfvc animated:YES completion:nil];
    
  } else {
    // configure alert controller strings
    NSString *alertTitle = NSLocalizedStringFromTable(@"defaultFailureTitle", @"AlertStrings", nil);
    NSString *alertMessage = NSLocalizedStringFromTable(@"openMailFailureMessage", @"AlertStrings", nil);
    NSString *acceptTitle = NSLocalizedStringFromTable(@"defaultAcceptTitle", @"AlertStrings", nil);
    
    // configure alert controller
    alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                          message:alertMessage
                                                   preferredStyle:UIAlertControllerStyleAlert];
    // configure accept action
    UIAlertAction *actionAccept = [UIAlertAction actionWithTitle:acceptTitle
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
    [alertController addAction:actionAccept];
    [self presentViewController:alertController animated:YES completion:nil];
  }
  
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
  [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

- (IBAction)returnToImageTop:(id)sender {
  CATransition *transition = [CATransition animation];
  transition.duration = 0.3;
  transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  transition.type = kCATransitionPush;
  transition.subtype = kCATransitionFromLeft;
  [self.view.window.layer addAnimation:transition forKey:nil];
  [self dismissViewControllerAnimated:NO completion:nil];
}

@end
