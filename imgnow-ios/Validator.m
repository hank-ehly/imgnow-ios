//
//  Validator.m
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/10/02.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "Validator.h"

@implementation Validator

- (NSMutableDictionary*)validateEmail:(NSString *)email {
    
    NSMutableDictionary *returnObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"",@"status",@"",@"reason", nil];
    
    if ([self validatePresence:email]) {
        
//        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"/\\^[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,4}\\$/i" options:0 error:nil];
        
        
    } else {
        returnObject[@"status"] = @"Failed";
        returnObject[@"reason"] = @"Presence";
    }
    
    return returnObject;
    
}

- (BOOL)validatePresence:(NSString *)string {
    if ([string length] == 0 || !string) {
        return NO;
    } else {
        return YES;
    }
}

@end
