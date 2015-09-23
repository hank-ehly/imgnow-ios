//
//  NSUserDefaults+Session.h
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/23.
//  Copyright © 2015年 Henry Ehly. All rightsreserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Session)

+ (id)sharedInstance;

- (void)createUserSessionWith:(NSData *)data andStatus:(NSString *)status;

@end
