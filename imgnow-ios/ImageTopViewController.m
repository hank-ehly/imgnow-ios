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

NSMutableArray *images;

- (void)viewDidLoad {
  [super viewDidLoad];
  _refreshControl = [[UIRefreshControl alloc] init];
  _refreshControl.backgroundColor = [UIColor purpleColor];
  _refreshControl.tintColor = [UIColor whiteColor];
  [_refreshControl addTarget:self action:@selector(queryForImages) forControlEvents:UIControlEventValueChanged];
  [_tableView addSubview:_refreshControl];
  
}

- (void)viewWillAppear:(BOOL)animated {
  [self queryForImages];
}

- (IBAction)goBack:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) queryForImages {
  
  NSString *userEmail = [[NSUserDefaults standardUserDefaults] valueForKey:@"user_email"];
  NSMutableURLRequest *request = [Api imagesIndexRequestForUser:userEmail];
  
  [Api fetchContentsOfRequest:request
                   completion:^(NSData *data, NSURLResponse *response, NSError *error) {
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                       
                       if (error) {
                         // handle error
                       }
                       
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

- (void)imagesIndexSuccess:(NSData*)data {
  NSData *responseJsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  images = [responseJsonData valueForKey:@"images"];
  [_tableView reloadData];
  if (_refreshControl) {
    [_refreshControl endRefreshing];
  }
}

- (NSDictionary*)timeLeftString:(int)timeUntilDeletion {
  
  NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:timeUntilDeletion];
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  
  NSString *format = [[NSString alloc] init];
  NSString *counter = [[NSString alloc] init];
  
  if (timeUntilDeletion >= 86400) {
    format = @"dd";
    counter = @"days";
  } else if (timeUntilDeletion >= 3600 && timeUntilDeletion < 86400) {
    format = @"hh";
    counter = @"hours";
  } else if (timeUntilDeletion >= 60 && timeUntilDeletion < 3600) {
    format = @"mm";
    counter = @"minutes";
  } else if (timeUntilDeletion < 60) {
    format = @"ss";
    counter = @"seconds";
  }
  
  [formatter setDateFormat:format];
  [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
  
  NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:[formatter stringFromDate:date], @"time", counter, @"counter", nil];
  return result;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {return [images count];}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
  
  NSMutableDictionary *currentRecord = [images objectAtIndex:indexPath.row];
  //    NSString *created_at = [currentRecord valueForKey:@"created_at"];
  int timeUntilDeletion = [[currentRecord valueForKey:@"time_until_deletion"] intValue];
  NSString *url = [[currentRecord valueForKey:@"file"] valueForKey:@"url"];
  
  NSDictionary *timeObject = [self timeLeftString:timeUntilDeletion];
  
  cell.textLabel.text = url;
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ left", [timeObject valueForKey:@"time"], [timeObject valueForKey:@"counter"]];
  
  return cell;
}

- (void)removeDeletedImage:(NSDictionary *)imageObject {
  
  [self queryForImages];
  
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    
    NSString *imageId = [[images objectAtIndex:indexPath.row] valueForKey:@"id"];
    NSMutableURLRequest *request = [Api imageDeleteRequest:imageId];
    
    [Api fetchContentsOfRequest:request
                     completion:^(NSData *data, NSURLResponse *response, NSError *error) {
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                         
                         if (error) {
                           // handle error
                         }
                         
                         switch ([Api statusCodeForResponse:response]) {
                           case 200:
                             [self queryForImages];
                             break;
                           case 500:
                             // handle internal error
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

- (void)didReceiveMemoryWarning {[super didReceiveMemoryWarning];}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {return YES;}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {return 64.0f;}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"imageDetail"]) {
    
    ImageDetailViewController *idvc = (ImageDetailViewController *)[segue destinationViewController];
    idvc.delegate = self;
    
    NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
    NSMutableDictionary *currentRecord = [images objectAtIndex:indexPath.row];
    NSString *created_at = [currentRecord valueForKey:@"created_at"];
    NSString *url = [[currentRecord valueForKey:@"file"] valueForKey:@"url"];
    NSString *updated_at = [currentRecord valueForKey:@"updated_at"];
    NSString *user_id = [currentRecord valueForKey:@"user_id"];
    NSString *image_id = [currentRecord valueForKey:@"id"];
    NSString *scheduledDeletionDate = [currentRecord valueForKey:@"scheduled_deletion_date"];
    NSDictionary *timeUntilDeletionObject = [self timeLeftString:[[currentRecord valueForKey:@"time_until_deletion"]intValue]];
    
    
    idvc.imageObject = [NSDictionary dictionaryWithObjectsAndKeys:created_at, @"created_at", url, @"url", updated_at, @"updated_at", user_id, @"user_id", image_id, @"image_id", scheduledDeletionDate, @"scheduledDeletionDate", timeUntilDeletionObject, @"timeUntilDeletionObject", nil];
    
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:NO];
    
  }
}

@end
