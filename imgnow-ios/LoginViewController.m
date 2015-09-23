//
//  LoginViewController.m
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/21.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "LoginViewController.h"
#import "NSUserDefaults+Session.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blur-bg-portrait.jpg"]];
    
}

- (void)didReceiveMemoryWarning {[super didReceiveMemoryWarning];}

- (IBAction)touchedLogin:(id)sender {

    NSString *routesFile = [[NSBundle mainBundle] pathForResource:@"api-routes" ofType:@"plist"];
    NSDictionary *routes = [NSDictionary dictionaryWithContentsOfFile:routesFile];
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [routes objectForKey:@"base"], [routes objectForKey:@"user_session"]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *urlSession = [NSURLSession sharedSession];
    
    NSString *email = _emailTextField.text;
    NSString *password = _passwordTextField.text;
    
    NSDictionary *loginCredentials = @{@"user":@{@"email":email,@"password":password}};
    NSData *requestJsonData = [NSJSONSerialization dataWithJSONObject:loginCredentials options:0 error:nil];
    request.HTTPBody = requestJsonData;
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    request.HTTPMethod = @"POST";
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSData *responseJsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
        long statusCode = [res statusCode];
        
        if (error) {
            NSLog(@"%@", error);
        }
        
        if (statusCode == 201) {
            
            [[NSUserDefaults sharedInstance] createUserSessionWith:responseJsonData];
            
            // have to perform segue on main block (gets switched after logout looks like..)
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self performSegueWithIdentifier:@"loggedIn" sender:nil];
            }];
            
        }
        
    }];
    
    [dataTask resume];
    
}

@end
