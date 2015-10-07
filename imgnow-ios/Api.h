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

// this method returns the login/logout/registration request object used in fetchContentsOfRequest
+ (NSMutableURLRequest*)sessionRequestForUser:(NSString*)uid
                                 identifiedBy:(NSString*)password
        isRegisteringWithPasswordConfirmation:(NSString*)passwordConfirmation;

// this method returns the request object used to create a new image for a user
+ (NSMutableURLRequest*)createImageRequest:(NSString*)imageString forUser:(NSString*)uid;

// returns the request object used to find all images for a user
+ (NSMutableURLRequest*)imagesIndexRequestForUser:(NSString*)uid;

+ (NSMutableURLRequest*)imageDeleteRequest:(NSString*)imageId;

+ (NSMutableURLRequest*)imageUpdateRequest:(NSString*)imageId;

+ (NSMutableURLRequest*)changePasswordRequestForUser:(NSString*)userEmail
                                        identifiedBy:(NSString*)currentPassword
                                     withNewPassword:(NSString*)password
                                       confirmedWith:(NSString*)passwordConfirmation;

// takes a request and performs it
+ (void)fetchContentsOfRequest:(NSMutableURLRequest *)request
                    completion:(void (^)(NSData *data,
                                         NSURLResponse *response,
                                         NSError *error)) completionHandler;

// takes an NSURLResponse and returns its status code
+ (long)statusCodeForResponse:(NSURLResponse*)response;

+ (NSString*)imgTagWithSrc:(NSString*)src;

+ (NSDictionary*)timeUntilDeletion:(int)time;

+ (NSURLProtectionSpace*)sharedProtectionSpace;

+ (BOOL)checkLoggedIn;

+ (void)clearCredentials;

@end
