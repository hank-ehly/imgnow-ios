//
//  RegistrationViewController.m
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/23.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "RegistrationViewController.h"
#import "NSUserDefaults+Session.h"

@interface RegistrationViewController ()

@end

@implementation RegistrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blur-bg-portrait.jpg"]];
}

- (void)viewWillAppear:(BOOL)animated {
    // this must be here, or else ViewController -> viewWillAppear gets called! (weird..)
}

- (void)didReceiveMemoryWarning {[super didReceiveMemoryWarning];}

- (IBAction)submitRegistration:(id)sender {
    
    NSString *routesFile = [[NSBundle mainBundle] pathForResource:@"api-routes" ofType:@"plist"];
    NSDictionary *routes = [NSDictionary dictionaryWithContentsOfFile:routesFile];
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [routes objectForKey:@"base"], [routes objectForKey:@"user_registration"]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *urlSession = [NSURLSession sharedSession];
    
    NSDictionary *credentials = @{@"user":@{@"email":_emailTextField.text,@"password":_passwordTextField.text,@"password_confirmation":_confirmPasswordTextField.text}};
    NSData *requestJsonData = [NSJSONSerialization dataWithJSONObject:credentials options:0 error:nil];
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
            
            [[NSUserDefaults sharedInstance] createUserSessionWith:responseJsonData andStatus:@"registered"];
            
            // have to perform segue on main block (gets switched after logout looks like..)
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self performSegueWithIdentifier:@"registered" sender:nil];
            }];
            
        }
        
    }];
    
    [dataTask resume];

    
}


@end
