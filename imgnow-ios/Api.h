//
//  Api.h
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/10/03.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Api : NSObject

// take a named route as a param
// returns the api-url for route in api-routes.plist.
// This method is needed to generate routes dynamically
// based on the "base" route, which changes
+ (NSURL*)fetchUrlForApiNamedRoute:(NSString*)namedRoute withResourceId:(NSString*)id;

// returns base route string
+ (NSString*)fetchBaseRouteString;

// returns dictionary object with all routes
+ (NSDictionary*)fetchApiRoutesDictionary;

// returns a url with a single appended query parameter
+ (NSURL*)url:(NSString*)namedRoute withQueryParameterKey:(NSString*)key forValue:(NSString*)value;

// this method returns the login request object used in fetchContentsOfRequest
+ (NSMutableURLRequest*)loginRequestForUser:(NSString*)uid
                               identifiedBy:(NSString*)password;

// takes a request and performs it
+ (void)fetchContentsOfRequest:(NSMutableURLRequest *)request
                    completion:(void (^)(NSData *data,
                                         NSURLResponse *response,
                                         NSError *error)) completionHandler;

+ (long)statusCodeForResponse:(NSURLResponse*)response;

@end
