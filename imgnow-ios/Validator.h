//
//  Validator.h
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/10/02.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Validator : NSObject

- (NSMutableDictionary*)validateEmail:(NSString*)email;
- (BOOL)validatePresence:(NSString*)string;

@end
