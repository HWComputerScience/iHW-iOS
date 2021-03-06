//
//  IHWAppDelegate.m
//  iHW
//
//  Created by Jonathan Burns on 7/10/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWAppDelegate.h"
#import "CJSONSerializer.h"
#import "IHWCurriculum.h"
#import "IHWDate.h"
#import "IHWFirstRunViewController.h"
#import "IHWScheduleViewController.h"
#import "IHWConstants.h"
#import "UIViewController+IHW.h"
#import "IHWNormalDay.h"
#import "IHWPeriod.h"

@implementation IHWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if (![IHWCurriculum yearSetManually]) [IHWCurriculum updateCurrentYear];
    
    // Override point for customization after application launch.
    UIViewController *rootVC = nil;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if ([IHWCurriculum isFirstRun])
            rootVC = [[IHWFirstRunViewController alloc] initWithNibName:@"IHWFirstRunViewController" bundle:nil];
        else
            rootVC = [[IHWScheduleViewController alloc] initWithNibName:@"IHWScheduleViewController" bundle:nil];
    } else {
        if ([IHWCurriculum isFirstRun])
            rootVC = [[IHWFirstRunViewController alloc] initWithNibName:@"IHWFirstRunViewController" bundle:nil]; //ADD IPAD VERSIONS HERE
        else
            rootVC = [[IHWScheduleViewController alloc] initWithNibName:@"IHWScheduleViewController" bundle:nil]; //ADD IPAD VERSIONS HERE
    }
    self.navController = [[UINavigationController alloc] initWithRootViewController:rootVC];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.navController.navigationBar.tintColor = [UIColor colorWithRed:0.6 green:0 blue:0 alpha:1];
    } else {
        self.navController.navigationBar.barTintColor = [UIColor colorWithRed:0.6 green:0 blue:0 alpha:1];
        self.navController.navigationBar.tintColor = [UIColor whiteColor];
        self.navController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
        self.navController.navigationBar.barStyle = UIBarStyleBlack;
    }
    
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)showNetworkIcon {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)hideNetworkIcon {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    [[IHWCurriculum reloadCurrentCurriculum].curriculumLoadingListeners addObject:self];
    self.fetchCallback = completionHandler;
    NSLog(@"Fetching...");
}

- (void)curriculumFinishedLoading:(IHWCurriculum *)curriculum {
    [curriculum.curriculumLoadingListeners removeObject:self];
    BackgroundFetchCallback callback = self.fetchCallback;
    self.fetchCallback = NULL;
    if (self.fetchCallback != NULL) callback(UIBackgroundFetchResultNewData);
}

- (void)curriculumFailedToLoad:(IHWCurriculum *)curriculum {
    [curriculum.curriculumLoadingListeners removeObject:self];
    BackgroundFetchCallback callback = self.fetchCallback;
    self.fetchCallback = NULL;
    if (self.fetchCallback != NULL) callback(UIBackgroundFetchResultFailed);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [self.window.rootViewController applicationDidEnterBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
