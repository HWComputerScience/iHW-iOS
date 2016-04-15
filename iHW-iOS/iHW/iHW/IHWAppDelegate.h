//
//  IHWAppDelegate.h
//  iHW
//
//  Created by Jonathan Burns on 7/10/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^BackgroundFetchCallback)(UIBackgroundFetchResult result);

@class IHWViewController;

@interface IHWAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navController;
@property (nonatomic, copy) BackgroundFetchCallback fetchCallback;

- (void)showNetworkIcon;
- (void)hideNetworkIcon;

@end
