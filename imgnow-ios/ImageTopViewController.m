//
//  ImageTopViewController.m
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/21.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "ImageTopViewController.h"
#import "ViewController.h"
#import "ImageDetailViewController.h"
#import "Api.h"

@interface ImageTopViewController ()

@end

@implementation ImageTopViewController

@synthesize images;
@synthesize alertController;

#pragma mark - View Load

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
  _refreshControl = [[UIRefreshControl alloc] init];
  [_refreshControl setBackgroundColor:[UIColor purpleColor]];
  [_refreshControl setTintColor:[UIColor whiteColor]];
  [_refreshControl addTarget:self action:@selector(queryForImages) forControlEvents:UIControlEventValueChanged];
  [_tableView addSubview:_refreshControl];
  [self queryForImages];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (IBAction)returnToCameraView:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) queryForImages {
  
  NSString *userEmail = [[NSUserDefaults standardUserDefaults] valueForKey:@"user_email"];
  NSMutableURLRequest *request = [Api imagesIndexRequestForUser:userEmail];
  
  [Api fetchContentsOfRequest:request
                   completion:
   
   ^(NSData *data, NSURLResponse *response, NSError *error) {
     
     dispatch_async(dispatch_get_main_queue(), ^{
       
       if (error) [self imagesIndexError:error];
       
       switch ([Api statusCodeForResponse:response]) {
         case 200:
           [self imagesIndexSuccess:data];
           break;
         default:
           NSLog(@"Status code %ld wasn't accounted for in ImageTopViewController.m queryForImages",
                 [Api statusCodeForResponse:response]);
           break;
       }
       
     });
     
   }];
  
}

#pragma mark - Async Callbacks

- (void)imagesIndexSuccess:(NSData*)data {
  
  // serialize success response into json
  NSData *responseJsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  
  // set the array of images equal to that of the response
  images = [responseJsonData valueForKey:@"images"];
  
  // reload the table
  [_tableView reloadData];
  
  // hide the refresh control
  if (_refreshControl) {
    [_refreshControl endRefreshing];
  }
  
}

- (void)imagesIndexError:(NSError*)error {
  
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

#pragma mark - Table View

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"
                                                          forIndexPath:indexPath];
  
  NSMutableDictionary *currentRecord = [images objectAtIndex:indexPath.row];
  
  NSString *url = [[currentRecord valueForKey:@"file"] valueForKey:@"url"];
  
  // format timeObject used to set cell text
  int timeUntilDeletion = [[currentRecord valueForKey:@"time_until_deletion"] intValue];
  NSDictionary *timeObject = [Api timeUntilDeletion:timeUntilDeletion];
  
  cell.textLabel.text = [Api imgTagWithSrc:url];
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ left",
                               [timeObject valueForKey:@"time"],
                               [timeObject valueForKey:@"counter"]];
  return cell;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    
    NSString *imageId = [[images objectAtIndex:indexPath.row] valueForKey:@"id"];
    NSMutableURLRequest *request = [Api imageDeleteRequest:imageId];
    
    [Api fetchContentsOfRequest:request
                     completion:
     
     ^(NSData *data, NSURLResponse *response, NSError *error) {
       
       dispatch_async(dispatch_get_main_queue(), ^{
         
         if (error) {
           // handle error
         }
         
         switch ([Api statusCodeForResponse:response]) {
           case 200:
             [self queryForImages];
             break;
           default:
             NSLog(@"Status code %ld wasn't accounted for in ImageTopViewController.m commitEditingStyle",
                   [Api statusCodeForResponse:response]);
             break;
         }
         
       });
     }];
    
  }
}

// Called by ImageDetailViewController as delegate method
- (void)removeDeletedImage:(NSDictionary *)imageObject {
  [self queryForImages];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [images count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 64.0f;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  
  if ([segue.identifier isEqualToString:@"imageDetail"]) {
    
    // set destination VC delegate to self
    ImageDetailViewController *idvc = (ImageDetailViewController *)[segue destinationViewController];
    idvc.delegate = self;
    
    // configure params you want to pass to ImageDetail
    NSIndexPath *indexPath                = [_tableView indexPathForSelectedRow];
    NSMutableDictionary *currentRecord    = [images objectAtIndex:indexPath.row];
    NSString *created_at                  = [currentRecord valueForKey:@"created_at"];
    NSString *url                         = [[currentRecord valueForKey:@"file"] valueForKey:@"url"];
    NSString *user_id                     = [currentRecord valueForKey:@"user_id"];
    NSString *image_id                    = [currentRecord valueForKey:@"id"];
    NSString *scheduledDeletionDate       = [currentRecord valueForKey:@"scheduled_deletion_date"];
    NSDictionary *timeUntilDeletionObject = [Api timeUntilDeletion:[[currentRecord valueForKey:@"time_until_deletion"]intValue]];
    
    // create dictionary object with all params
    idvc.imageObject = [NSDictionary dictionaryWithObjectsAndKeys:
                        created_at, @"created_at",
                        url, @"url",
                        user_id, @"user_id",
                        image_id, @"image_id",
                        scheduledDeletionDate, @"scheduledDeletionDate",
                        timeUntilDeletionObject, @"timeUntilDeletionObject",
                        nil];
    
    // deselct table view cell so it doesn't stay highlighted
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:NO];
    
  }
}

@end
