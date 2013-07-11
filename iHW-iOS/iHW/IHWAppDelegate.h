//
//  IHWAppDelegate.h
//  iHW
//
//  Created by Andrew Friedman on 6/14/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IHWScheduleViewController;

@interface IHWAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) IHWScheduleViewController *viewController;

@end
