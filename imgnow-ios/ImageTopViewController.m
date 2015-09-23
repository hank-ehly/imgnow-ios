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

@interface ImageTopViewController ()

@end

@implementation ImageTopViewController

NSMutableArray *images;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [self queryForImages];
}

- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) queryForImages {
    
    NSString *routesFile = [[NSBundle mainBundle] pathForResource:@"api-routes" ofType:@"plist"];
    NSDictionary *routes = [NSDictionary dictionaryWithContentsOfFile:routesFile];
    NSString *queryParams = [NSString stringWithFormat:@"email=%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"user_email"]];
    NSString *urlString = [NSString stringWithFormat:@"%@%@?%@", [routes objectForKey:@"base"], [routes objectForKey:@"api_images_index"], queryParams];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *urlSession = [NSURLSession sharedSession];
    
    

    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSData *responseJsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
            long statusCode = [res statusCode];
            
            if (error) {
                NSLog(@"%@", error);
            }
            
            if (statusCode == 200) {
                
                images = [responseJsonData valueForKey:@"images"];
                [_tableView reloadData];
                
            }
            
            });
        
        }];
    
    [dataTask resume];
    
    

}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {return [images count];}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSMutableDictionary *currentRecord = [images objectAtIndex:indexPath.row];
    NSString *created_at = [currentRecord valueForKey:@"created_at"];
    NSString *url = [[currentRecord valueForKey:@"file"] valueForKey:@"url"];
    
    cell.textLabel.text = url;
    cell.detailTextLabel.text = created_at;

    return cell;
}

- (void)removeDeletedImage:(NSDictionary *)imageObject {

    [self queryForImages];
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // pressed delete
        NSString *routesFile = [[NSBundle mainBundle] pathForResource:@"api-routes" ofType:@"plist"];
        NSDictionary *routes = [NSDictionary dictionaryWithContentsOfFile:routesFile];
        
        NSString *img_id = [[images objectAtIndex:indexPath.row] valueForKey:@"id"];
        
        NSString *urlString = [NSString stringWithFormat:@"%@%@%@.json", [routes objectForKey:@"base"], [routes objectForKey:@"api_image_delete"], img_id];
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSURLSession *urlSession = [NSURLSession sharedSession];
        
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        request.HTTPMethod = @"DELETE";
        
        NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{

                NSData *responseJsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                //        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
                //        long statusCode = [res statusCode];
                
                if (error) {
                    NSLog(@"%@", error);
                }
                
                NSLog(@"%@", responseJsonData);

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
        
        
        idvc.imageObject = [NSDictionary dictionaryWithObjectsAndKeys:created_at, @"created_at", url, @"url", updated_at, @"updated_at", user_id, @"user_id", image_id, @"image_id", nil];
        
        [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:NO];

    }
}

@end
