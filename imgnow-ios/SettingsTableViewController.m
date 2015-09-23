//
//  SettingsTableViewController.m
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/21.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "SettingsTableViewController.h"

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
        
        [self logoutUser];
        
    }
    
}

#pragma mark - Table view data source

- (void)logoutUser {
    
    NSString *routesFile = [[NSBundle mainBundle] pathForResource:@"api-routes" ofType:@"plist"];
    NSDictionary *routes = [NSDictionary dictionaryWithContentsOfFile:routesFile];
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [routes objectForKey:@"base"], [routes objectForKey:@"destroy_user_session"]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *urlSession = [NSURLSession sharedSession];
    
    NSDictionary *loginCredentials = @{@"user":@{@"email":[[NSUserDefaults standardUserDefaults] valueForKey:@"user_email"]}};
    NSData *requestJsonData = [NSJSONSerialization dataWithJSONObject:loginCredentials options:0 error:nil];
    request.HTTPBody = requestJsonData;
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    request.HTTPMethod = @"DELETE";
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
        long statusCode = [res statusCode];
        
        if (error) {
            NSLog(@"%@", error);
        }
        
        if (statusCode == 200) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_email"];
            [self performSegueWithIdentifier:@"logout" sender:nil];
        }

        
    }];
    
    [dataTask resume];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.0f;
}

@end
