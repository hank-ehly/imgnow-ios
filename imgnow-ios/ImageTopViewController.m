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

NSArray *fakeTitles;
NSArray *fakeDetails;

NSArray *images;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    fakeTitles = [NSArray arrayWithObjects:@"6f73hf84", @"u57s21k0", @"7f82hcmx", @"7d51k8m0", @"0sg1nna4", @"8h92h7vu", nil];
    fakeDetails = [NSArray arrayWithObjects:@"28 days left", @"23 days left", @"19 days left", @"17 days left", @"10 days left", @"1 day left", nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    NSString *routesFile = [[NSBundle mainBundle] pathForResource:@"api-routes" ofType:@"plist"];
    NSDictionary *routes = [NSDictionary dictionaryWithContentsOfFile:routesFile];
    NSString *queryParams = [NSString stringWithFormat:@"email=%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"user_email"]];
    NSString *urlString = [NSString stringWithFormat:@"%@%@?%@", [routes objectForKey:@"base"], [routes objectForKey:@"api_images_index"], queryParams];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *urlSession = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
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
        
    }];
    
    [dataTask resume];
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {return [images count];}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSMutableDictionary *currentRecord = [images objectAtIndex:indexPath.row];
    NSString *created_at = [currentRecord valueForKey:@"created_at"];
    NSString *url = [[currentRecord valueForKey:@"file"] valueForKey:@"url"];
//    NSString *updated_at = [currentRecord valueForKey:@"updated_at"];
//    NSString *user_id = [currentRecord valueForKey:@"user_id"];
//    NSString *image_id = [currentRecord valueForKey:@"id"];
    
    cell.textLabel.text = url;
    cell.detailTextLabel.text = created_at;

    return cell;
}

- (void)didReceiveMemoryWarning {[super didReceiveMemoryWarning];}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {return YES;}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {return 64.0f;}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"imageDetail"]) {
        
        ImageDetailViewController *idvc = (ImageDetailViewController *)[segue destinationViewController];
        idvc.delegate = self;
        
        idvc.image_url = [_tableView cellForRowAtIndexPath:[_tableView indexPathForSelectedRow]].textLabel.text;
        
        [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];

    }
}

@end
