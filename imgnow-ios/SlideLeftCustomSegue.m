//
//  SlideLeftCustomSegue.m
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/23.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "SlideLeftCustomSegue.h"
#import <QuartzCore/QuartzCore.h>

@implementation SlideLeftCustomSegue

- (void) perform {
    
    UIViewController *srcViewController = (UIViewController *) self.sourceViewController;
    UIViewController *destViewController = (UIViewController *) self.destinationViewController;
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [srcViewController.view.window.layer addAnimation:transition forKey:nil];
    
    [srcViewController presentViewController:destViewController animated:NO completion:nil];
    
}

@end
