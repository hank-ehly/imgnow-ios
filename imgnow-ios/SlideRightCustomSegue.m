//
//  SlideRightCustomSegue.m
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/10/06.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "SlideRightCustomSegue.h"
#import <QuartzCore/QuartzCore.h>

@implementation SlideRightCustomSegue

- (void) perform {
  
  UIViewController *srcViewController = (UIViewController *) self.sourceViewController;
  UIViewController *destViewController = (UIViewController *) self.destinationViewController;
  
  CATransition *transition = [CATransition animation];
  transition.duration = 0.3;
  transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  transition.type = kCATransitionPush;
  transition.subtype = kCATransitionFromLeft;
  [srcViewController.view.window.layer addAnimation:transition forKey:nil];
  
  [srcViewController presentViewController:destViewController animated:NO completion:nil];
  
}

@end
