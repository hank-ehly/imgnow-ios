//
//  Api.m
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/10/03.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "Api.h"

@implementation Api

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
