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

- (void)createUserSessionWith:(NSData *)data {
    [self setObject:[data valueForKey:@"email"] forKey:@"user_email"];

}

@end
