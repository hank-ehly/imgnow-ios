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

+ (NSMutableURLRequest*)sessionRequestForUser:(NSString *)uid
                                 identifiedBy:(NSString *)password
        isRegisteringWithPasswordConfirmation:(NSString *)passwordConfirmation {
  
  // determine type of request based on provided information
  // options: login, logout, registration
  NSString *namedRoute = [[NSString alloc] init];
  if (uid != nil && password != nil && passwordConfirmation == nil) {
    namedRoute = @"user_session"; // login
  } else if (password == nil) {
    namedRoute = @"destroy_user_session"; // logout
  } else if (passwordConfirmation) {
    namedRoute = @"user_registration"; // registering
  }
  
  // login & registration are POST while logout is DELETE
  NSString *requestType = [namedRoute isEqualToString:@"destroy_user_session"] ? @"DELETE" : @"POST";
  
  // get the full named route as NSURL
  NSURL *url = [self fetchUrlForApiNamedRoute:namedRoute withResourceId:nil];
  
  // serialize session credentials
  NSData *credentials = [self serializedSessionCredentialsForUser:uid
                                                     identifiedBy:password
                                                      confirmedBy:passwordConfirmation];
  
  // create HTTP request object
  NSMutableURLRequest *request = [self jsonRequestWithUrl:(NSURL*)url
                                                   ofType:requestType
                                             withHTTPBody:credentials
                                      andTimeoutInSeconds:10];
  
  return request;
  
}

+ (NSMutableURLRequest *)createImageRequest:(NSString *)imageString forUser:(NSString *)uid {
  
  // retrieve named route
  NSURL *url = [Api fetchUrlForApiNamedRoute:@"api_images_create" withResourceId:nil];
  
  // format body content
  NSData *httpBodyContent = [self jsonFormatNewImageString:imageString forUser:uid];
  
  // create and return HTTP request object
  NSMutableURLRequest *request = [self jsonRequestWithUrl:url
                                                   ofType:@"POST"
                                             withHTTPBody:httpBodyContent
                                      andTimeoutInSeconds:10];
  return request;
  
}

+ (NSMutableURLRequest *)imagesIndexRequestForUser:(NSString *)uid {
  
  // retrieve named route
  NSURL *url = [self url:@"api_images_index" withQueryParameterKey:@"email" forValue:uid];
  
  // create and return HTTP request object
  NSMutableURLRequest *request = [self jsonRequestWithUrl:url
                                                   ofType:@"GET"
                                             withHTTPBody:nil
                                      andTimeoutInSeconds:10];
  
  return request;
  
}

+ (NSMutableURLRequest *)imageDeleteRequest:(NSString *)imageId {
  
  // retrieve named route
  NSURL *url = [self fetchUrlForApiNamedRoute:@"api_image_delete" withResourceId:imageId];
  
  // create and return HTTP request object
  NSMutableURLRequest *request = [self jsonRequestWithUrl:url
                                                   ofType:@"DELETE"
                                             withHTTPBody:nil
                                      andTimeoutInSeconds:10];
  
  return request;
  
}

+ (NSMutableURLRequest *)imageUpdateRequest:(NSString *)imageId {
  
  // retrieve named route
  NSURL *url = [self fetchUrlForApiNamedRoute:@"api_images_update" withResourceId:imageId];
  
  // create and return HTTP request object
  NSMutableURLRequest *request = [self jsonRequestWithUrl:url
                                                   ofType:@"PATCH"
                                             withHTTPBody:nil
                                      andTimeoutInSeconds:10];
  
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

+ (NSData*)jsonFormatNewImageString:(NSString*)imageString forUser:(NSString*)uid {
  
  // create dictionary object of necessary data
  NSDictionary *dataDictionary = @{ @"image":imageString,
                                    @"authenticity_token":@"",
                                    @"utf8":@"✓",
                                    @"email":uid
                                    };
  
  // serialize it into json so rails can interpret it
  NSData *serializedJsonData = [NSJSONSerialization dataWithJSONObject:dataDictionary
                                                               options:0
                                                                 error:nil];
  
  return serializedJsonData;
  
}

+ (NSMutableURLRequest*)jsonRequestWithUrl:(NSURL*)url
                                    ofType:(NSString*)type
                              withHTTPBody:(NSData*)httpBody
                       andTimeoutInSeconds:(int)seconds {
  
  // create HTTP request object
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  
  // this is a JSON request
  [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
  
  // set timeout of request dynamically
  [request setTimeoutInterval:seconds];
  
  // set type of request dynamically
  request.HTTPMethod = type;
  
  // set login credentials if this is a login request
  if (httpBody) [request setHTTPBody:httpBody];
  
  return request;
  
}

+ (NSData*)serializedSessionCredentialsForUser:(NSString*)uid
                                  identifiedBy:(NSString*)password
                                   confirmedBy:(NSString*)passwordConfirmation {
  
  // We put things in this dictionary before serializing it into JSON
  NSDictionary *credentialsDictionaryObject = [[NSDictionary alloc] init];
  
  // Based on the request type, add certain parameters to the dictionary
  if (uid != nil && password != nil && passwordConfirmation == nil) { // login
    credentialsDictionaryObject = @{ @"user": @{ @"email":uid, @"password":password } };
    
  } else if (uid != nil && password == nil && passwordConfirmation == nil) { // logout
    credentialsDictionaryObject = @{ @"user": @{ @"email":uid } };
    
  } else if (uid != nil && password != nil && passwordConfirmation != nil) { // registration
    credentialsDictionaryObject = @{ @"user": @{
                                         @"email":uid,
                                         @"password":password,
                                         @"password_confirmation":passwordConfirmation
                                         }
                                     };
  }
  
  // serialize the dictionary into json and return its
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

+ (NSString *)imgTagWithSrc:(NSString *)src {
  NSString *beg = @"<img src=\"";
  NSString *end = @"\"></img>";
  NSString *concat = [NSString stringWithFormat:@"%@%@%@", beg, src, end];
  return concat;
}

+ (NSDictionary*)timeUntilDeletion:(int)time {
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:time];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    NSString *format = [[NSString alloc] init];
    NSString *counter = [[NSString alloc] init];
    
    if (time >= 86400) {
      format = @"dd";
      counter = @"days";
    } else if (time >= 3600 && time < 86400) {
      format = @"hh";
      counter = @"hours";
    } else if (time >= 60 && time < 3600) {
      format = @"mm";
      counter = @"minutes";
    } else if (time < 60) {
      format = @"ss";
      counter = @"seconds";
    }
    
    [formatter setDateFormat:format];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
                            [formatter stringFromDate:date], @"time", counter, @"counter", nil];
    return result;
  
}

@end
