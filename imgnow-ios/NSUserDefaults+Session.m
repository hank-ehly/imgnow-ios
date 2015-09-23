//
//  NSUserDefaults+Session.m
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/23.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "NSUserDefaults+Session.h"

@implementation NSUserDefaults (Session)

+ (id)sharedInstance {
    static NSUserDefaults *defaults = nil;
    @synchronized(self) {
        if (defaults == nil) {
            defaults = [self standardUserDefaults];
        }
    }
    return defaults;
}

- (void)createUserSessionWith:(NSData *)data andStatus:(NSString *)status {
    
    [self setObject:[data valueForKey:@"email"] forKey:@"user_email"];
    
    if ([status isEqualToString:@"loggedin"]) {
        [self setObject:@"Successfully logged in." forKey:@"welcomeMessage"];
    } else if ([status isEqualToString:@"registered"]) {
        [self setObject:@"Account created successfully." forKey:@"welcomeMessage"];
    }
}

@end
