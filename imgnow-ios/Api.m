//
//  Api.m
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/10/03.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "Api.h"

@implementation Api

#pragma mark - API Request Builders

+ (NSMutableURLRequest*)accessRequestForUser:(NSString *)uid
                                identifiedBy:(NSString *)password
       isRegisteringWithPasswordConfirmation:(NSString *)passwordConfirmation {
  
  // is it a login or registration request?
  NSString *namedRoute = passwordConfirmation != nil ? @"user_registration" : @"user_session";
  NSURL *url = [self fetchUrlForApiNamedRoute:namedRoute withResourceId:nil];
  
  // format login credentials
  NSData *credentials = [self jsonAccessCredentialsForUser:uid
                                              identifiedBy:password
                                               confirmedBy:passwordConfirmation];
  
  // create HTTP request object
  NSMutableURLRequest *request = [self jsonRequestWithUrl:(NSURL*)url
                                                   ofType:@"POST"
                                      withTimeoutInterval:10
                                     withLoginCredentials:credentials];
  
  return request;
  
}

+ (void)fetchContentsOfRequest:(NSMutableURLRequest *)request
                    completion:(void (^)(NSData *data,
                                         NSURLResponse *response,
                                         NSError *error)) completionHandler {
  
  NSURLSessionDataTask *dataTask =
  [[NSURLSession sharedSession] dataTaskWithRequest:request
                                  completionHandler:
   
   ^(NSData *data, NSURLResponse *response, NSError *error) {
     
     if (completionHandler == nil) return;
     
     if (error) {
       completionHandler(nil, response, error);
       return;
     }
     completionHandler(data, response, nil);
   }];
  
  [dataTask resume];
  
}

#pragma mark - JSON Formatting

+ (NSMutableURLRequest*)jsonRequestWithUrl:(NSURL*)url
                                    ofType:(NSString*)type
                       withTimeoutInterval:(int)timeoutInterval
                      withLoginCredentials:(NSData*)credentials {
  
  // create HTTP request object
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  
  // this is a JSON request
  [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
  
  // set timeout of request dynamically
  [request setTimeoutInterval:timeoutInterval];
  
  // set type of request dynamically
  request.HTTPMethod = type;
  
  // set login credentials if this is a login request
  if (credentials) [request setHTTPBody:credentials];
  
  return request;
  
}

+ (NSData*)jsonAccessCredentialsForUser:(NSString*)uid
                           identifiedBy:(NSString*)password
                            confirmedBy:(NSString*)passwordConfirmation {
  
  NSDictionary *credentialsDictionaryObject = [[NSDictionary alloc] init];
  
  if (passwordConfirmation) {
    credentialsDictionaryObject = @{ @"user": @{
                                         @"email":uid,
                                         @"password":password,
                                         @"password_confirmation":passwordConfirmation
                                         }
                                     };
  } else {
    credentialsDictionaryObject = @{ @"user": @{
                                         @"email":uid,
                                         @"password":password
                                         }
                                     };
  }
  
  // serialize the login credentials to json
  NSData *credentialsJsonObject = [NSJSONSerialization
                                   dataWithJSONObject:credentialsDictionaryObject
                                   options:0
                                   error:nil];
  
  return credentialsJsonObject;
  
}

#pragma mark - API Routes

+ (NSURL *)fetchUrlForApiNamedRoute:(NSString *)namedRoute withResourceId:(NSString *)id {
  
  // get api-routes.plist dictionary object
  NSDictionary *apiRoutesDictionary = [self fetchApiRoutesDictionary];
  
  // create route string
  NSString *fullNamedRouteString = [NSString stringWithFormat:@"%@%@",
                                    [apiRoutesDictionary objectForKey:@"base"],
                                    [apiRoutesDictionary objectForKey:namedRoute]];
  
  // append resource id if passed as parameter
  if (id) {
    NSString *appendedId = [NSString stringWithFormat:@"%@.json", id];
    fullNamedRouteString = [fullNamedRouteString stringByAppendingString:appendedId];
  }
  
  // NSURL of route string
  NSURL *url = [NSURL URLWithString:fullNamedRouteString];
  
  return url;
  
}

+ (NSString *)fetchBaseRouteString {
  
  // get api-routes.plist dictionary object
  NSDictionary *apiRoutesDictionary = [self fetchApiRoutesDictionary];
  
  // get base route string
  NSString *baseRouteString = [apiRoutesDictionary valueForKey:@"base"];
  
  return baseRouteString;
  
}

+ (NSDictionary*)fetchApiRoutesDictionary {
  
  // get api-routes.plist path
  NSString *apiRoutesFilePath = [[NSBundle mainBundle] pathForResource:@"api-routes"
                                                                ofType:@"plist"];
  
  // get api-routes.plist dictionary object
  NSDictionary *apiRoutesDictionary = [NSDictionary dictionaryWithContentsOfFile:apiRoutesFilePath];
  
  return apiRoutesDictionary;
  
}

+ (NSURL *)url:(NSString *)namedRoute withQueryParameterKey:(NSString *)key forValue:(NSString *)value {

  // get initial named route string
  NSString *routeString = [NSString stringWithFormat:@"%@",
                           [self fetchUrlForApiNamedRoute:namedRoute withResourceId:nil]];
  
  // append query parameter
  routeString = [routeString stringByAppendingString:
                 [NSString stringWithFormat:@"?%@=%@", key, value]];
  
  // create NSURL
  NSURL *url = [NSURL URLWithString:routeString];
  
  return url;
  
}

#pragma mark - Utility Methods

+ (long)statusCodeForResponse:(NSURLResponse *)response {
  return (long)[(NSHTTPURLResponse *)response statusCode];
}

@end
