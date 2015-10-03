//
//  Api.m
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/10/03.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "Api.h"

@implementation Api

+ (NSMutableURLRequest*)loginRequestForUser:(NSString *)uid
                              identifiedBy:(NSString *)password {
  
  // get login url
  NSURL *url = [self fetchUrlForApiNamedRoute:@"user_session" withResourceId:nil];
  
  // format login credentials
  NSData *credentials = [self jsonLoginCredentialsForUser:uid identifiedBy:password];
  
  // create HTTP request object
  NSMutableURLRequest *request = [self jsonRequestWithUrl:(NSURL*)url
                                                   ofType:@"POST"
                                      withTimeoutInterval:(NSTimeInterval*)10
                                     withLoginCredentials:credentials];
  
  return request;
  
}

+ (void)fetchContentsOfRequest:(NSMutableURLRequest *)request
                completion:(void (^)(NSData *data, NSError *error)) completionHandler {
  
  NSURLSessionDataTask *dataTask =
  [[NSURLSession sharedSession] dataTaskWithRequest:request
                              completionHandler:
   
   ^(NSData *data, NSURLResponse *response, NSError *error) {
     
     if (completionHandler == nil) return;
     
     if (error) {
       completionHandler(nil, error);
       return;
     }
     completionHandler(data, nil);
   }];
  
  [dataTask resume];
  
}

+ (NSMutableURLRequest*)jsonRequestWithUrl:(NSURL*)url
                                    ofType:(NSString*)type
                       withTimeoutInterval:(NSTimeInterval*)timeoutInterval
                      withLoginCredentials:(NSData*)credentials {
  
  // create HTTP request object
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  
  // this is a JSON request
  [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
  
  // set timeout of request dynamically
  [request setTimeoutInterval:*timeoutInterval];
  
  // set type of request dynamically
  request.HTTPMethod = type;
  
  // set login credentials if this is a login request
  if (credentials) [request setHTTPBody:credentials];
  
  return request;
  
}

+ (NSData*)jsonLoginCredentialsForUser:(NSString*)uid
                          identifiedBy:(NSString*)password {
  
  // create dictionary of login credentials to send as parameters
  NSDictionary *credentialsDictionaryObject = @{ @"user": @{
                                                     @"email":uid,
                                                     @"password":password
                                                     }
                                                 };
  
  // serialize the login credentials to json
  NSData *credentialsJsonObject = [NSJSONSerialization
                                   dataWithJSONObject:credentialsDictionaryObject
                                   options:0
                                   error:nil];
  
  return credentialsJsonObject;
  
}

#pragma mark - Routes

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

+ (NSURL *)url:(NSString *)namedRoute
           withQueryParameterKey:(NSString *)key
           forValue:(NSString *)value {

  // get initial named route string
  NSString *routeString = [NSString stringWithFormat:@"%@",
                      [self fetchUrlForApiNamedRoute:namedRoute withResourceId:nil]];
  
  // append query parameter
  routeString = [routeString stringByAppendingString:
                          [NSString stringWithFormat:@"?%@=%@", key, value]];
  
  // create url
  NSURL *url = [NSURL URLWithString:routeString];
  
  return url;
  
}

@end
