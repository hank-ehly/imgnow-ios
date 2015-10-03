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
  NSURL *url = [Api url:@"api_images_index" withQueryParameterKey:@"user_email" forValue:userEmail];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *urlSession = [NSURLSession sharedSession];
  
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
            long statusCode = [res statusCode];
            
            if (error || data == nil) {
                NSLog(@"%@", error);
            }
            
            if (statusCode == 200) {
                NSData *responseJsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                images = [responseJsonData valueForKey:@"images"];
                [_tableView reloadData];
                
                if (_refreshControl) {
                    [_refreshControl endRefreshing];
                }
                
            }
            
            });
        
        }];
    
    [dataTask resume];
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
      
      NSString *img_id = [[images objectAtIndex:indexPath.row] valueForKey:@"id"];
      NSURL *url = [Api fetchUrlForApiNamedRoute:@"api_image_delete" withResourceId:img_id];
    
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSURLSession *urlSession = [NSURLSession sharedSession];
        
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        request.HTTPMethod = @"DELETE";
        
        NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (error) {
                    NSLog(@"%@", error);
                }

                [self queryForImages];
                
            });
            
            
        }];
        
        [dataTask resume];
        
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
