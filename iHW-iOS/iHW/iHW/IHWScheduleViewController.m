//
//  IHWScheduleViewController.m
//  iHW
//
//  Created by Jonathan Burns on 8/12/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWScheduleViewController.h"
#import "IHWDate.h"
#import "IHWDayViewController.h"
#import "IHWNormalCoursesViewController.h"
#import "ActionSheetDatePicker.h"
#import "IHWPreferencesViewController.h"
#import "IHWChangeYearViewController.h"
#import "IHWNotificationOptionsViewController.h"
#import "IHWAppDelegate.h"
#import <PDTSimpleCalendar/PDTSimpleCalendar.h>
@implementation IHWScheduleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"My Schedule";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Set up bar buttons
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Courses" style:UIBarButtonItemStyleBordered target:self action:@selector(showCourses)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        //in iOS 6, if you want borderless buttons in the navigation bar, you need to add a UIToolbar as the right button and add the actual buttons to the UIToolbar.
        //Also use the old icon
        UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"whitegear_old"] style:UIBarButtonItemStylePlain target:self action:@selector(optionsButtonClicked)];
        NSArray *buttons = @[item2, item1];
        UIToolbar *tools = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,64,44)];
        tools.clipsToBounds = NO;
        tools.barStyle = -1;
        [tools setItems:buttons animated:NO];
        UIBarButtonItem *rightButtons = [[UIBarButtonItem alloc] initWithCustomView:tools];
        self.navigationItem.rightBarButtonItem = rightButtons;
    } else {
        //in iOS 7, borderless buttons are the default, so we can just add the buttons directly to the navigation bar
        UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"whitegear"] style:UIBarButtonItemStylePlain target:self action:@selector(optionsButtonClicked)];
        self.navigationItem.rightBarButtonItems = @[item1, item2];
    }
    
    //Add a scrolling UIPageViewController for the IHWDayViewControllers
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    //Keep a dictionary mapping IHWDate objects to IHWDayViewControllers
    self.loadedViewControllers = [NSMutableDictionary dictionary];
    //Setup a loading queue
    self.queue = [[NSOperationQueue alloc] init];
    
    //Add a blank view controller as a placeholder before the actual viewcontrollers load
    [self.pageViewController setViewControllers:[NSArray arrayWithObject:[[UIViewController alloc] init]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    //Add the UIPageViewController to the view
    [self addChildViewController:self.pageViewController];
    self.pageViewController.view.frame = self.pageContainerView.bounds;
    [self.pageContainerView addSubview:self.pageViewController.view];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        //Setup the UI for iOS 6
        self.topSpaceConstraint.constant = 0;
        self.toolbar.tintColor = [UIColor colorWithRed:.6 green:0 blue:0 alpha:1];
        self.backItem.image = [UIImage imageNamed:@"backbutton_old"];
        self.forwardItem.image = [UIImage imageNamed:@"forwardbutton_old"];
        self.gotoDateItem.image = nil;
        self.gotoDateItem.title = @"Goto Date...";
        self.todayItem.image = nil;
        self.todayItem.title = @"Today";
    } else {
        //Ask the user if they want notifications (as long as they haven't dismissed this dialog before)
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"seenNotifications"] != YES) {
            [[[UIAlertView alloc] initWithTitle:@"Want Notifications?" message:@"iHW can notify you at the end of your free periods when you have class next period." delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"More Info...", @"Ask Later", nil] show];
        }
    }
    
    //Initialize Calendar
    _calendar = [[PDTSimpleCalendarViewController alloc]init];
    _calendar.delegate = self;
    
    _calControl = [[UINavigationController alloc]initWithRootViewController:_calendar];
    _calControl.navigationBar.barTintColor = [UIColor colorWithRed:.6 green:0 blue:0 alpha:1];
    UIButton *done = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 40)];
    [done addTarget:self action:@selector(finishedSelection:) forControlEvents:UIControlEventTouchUpInside];
    [done setTitle:@"Done" forState:UIControlStateNormal];
    [_calControl.navigationBar addSubview:done];
}

- (void)viewWillAppear:(BOOL)animated {
    if (![[IHWCurriculum currentCurriculum] isLoaded]) {
        //If the curriculum hasn't loaded, setup a callback to be notified when it loads
        if (![[IHWCurriculum currentCurriculum].curriculumLoadingListeners containsObject:self])
            [[IHWCurriculum currentCurriculum].curriculumLoadingListeners addObject:self];
        //show the loading spinner
        self.loadingView = [[IHWLoadingView alloc] initWithText:@"Loading..."];
    } else {
        [self curriculumFinishedLoading:[IHWCurriculum currentCurriculum]];
        /*if (self.currentDate == nil) self.currentDate = [IHWDate today];
        //Set the current view controller to the day view for today
        [self.loadedViewControllers setObject:[[IHWDayViewController alloc] initWithDate:self.currentDate] forKey:self.currentDate];
        [self.pageViewController setViewControllers:[NSArray arrayWithObject:[self.loadedViewControllers objectForKey:self.currentDate]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        //Begin caching two days before and after today in the background
        if (self.queue.operationCount == 0) [self.queue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(cacheViewControllersAroundDate:) object:self.currentDate]];*/
    }
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)curriculumFinishedLoading:(IHWCurriculum *)curriculum {
    //NSLog(@"Curriculum finished loading");
    if (self.loadingView != nil) {
        [self.loadingView dismiss];
        self.loadingView = nil;
    }
    //Don't receive any more callbacks
    [curriculum.curriculumLoadingListeners removeObject:self];
    if (self.currentDate == nil) self.currentDate = [IHWDate today];
    //If today is out of bounds, go to the closest date that is in bounds
    if ([self.currentDate compare:[[IHWDate alloc] initWithMonth:7 day:1 year:[IHWCurriculum currentYear]]] == NSOrderedAscending) {
        self.currentDate = [[IHWDate alloc] initWithMonth:7 day:1 year:[IHWCurriculum currentYear]];
    }
    else if ([self.currentDate compare:[[IHWDate alloc] initWithMonth:7 day:1 year:[IHWCurriculum currentYear]+1]] != NSOrderedAscending) {
        self.currentDate = [[[IHWDate alloc] initWithMonth:7 day:1 year:[IHWCurriculum currentYear]+1] dateByAddingDays:-1];
    }
    //Set the current view controller to the day view for today
    [self.loadedViewControllers setObject:[[IHWDayViewController alloc] initWithDate:self.currentDate] forKey:self.currentDate];
    [self.pageViewController setViewControllers:[NSArray arrayWithObject:[self.loadedViewControllers objectForKey:self.currentDate]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    //Begin caching two days before and after today in the background
    if (self.queue.operationCount == 0) [self.queue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(cacheViewControllersAroundDate:) object:self.currentDate]];
}

- (void)curriculumFailedToLoad:(IHWCurriculum *)curriculum {
    //NSLog(@"Curriculum failed to load");
    [self.loadingView dismiss];
    [curriculum.curriculumLoadingListeners removeObject:self];
    self.loadingView = nil;
    //Show an alert
    if (self.unavailableAlert == nil) {
        self.unavailableAlert = [[UIAlertView alloc] initWithTitle:@"Schedule Currently Unavailable" message:@"Please check your internet connection and try again later." delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:@"Choose year", nil];
        [self.unavailableAlert show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.unavailableAlert = nil;
    if (alertView == self.unavailableAlert && buttonIndex == 0) {
        //User clicked "Retry" on the "Unavailable" dialog
        [[IHWCurriculum currentCurriculum].curriculumLoadingListeners addObject:self];
        [[IHWCurriculum currentCurriculum] loadEverythingWithStartingDate:[IHWDate today]];
        self.loadingView = [[IHWLoadingView alloc] initWithText:@"Loading..."];
    } else if (alertView == self.unavailableAlert && buttonIndex == 1) {
        //User clicked "Choose Year" on the "Unavailable" dialog
        //Show the preferences panel in a new modal UINavigationController
        UINavigationController *navc = [[UINavigationController alloc] init];
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            navc.navigationBar.tintColor = [UIColor colorWithRed:0.6 green:0 blue:0 alpha:1];
        } else {
            navc.navigationBar.barTintColor = [UIColor colorWithRed:0.6 green:0 blue:0 alpha:1];
            navc.navigationBar.tintColor = [UIColor whiteColor];
            navc.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
            navc.navigationBar.barStyle = UIBarStyleBlack;
        }
        navc.viewControllers = @[[[IHWPreferencesViewController alloc] initWithStyle:UITableViewStyleGrouped], [[IHWChangeYearViewController alloc] initWithStyle:UITableViewStyleGrouped]];
        [self presentViewController:navc animated:YES completion:nil];
    } else if (buttonIndex == 0) {
        //User clicked "No thanks" on the "Want notifications?" dialog
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"seenNotifications"];
    } else if (buttonIndex == 1) {
        //User clicked "More info" on the "Want notifications?" dialog
        //Show the preferences panel in a new modal UINavigationController
        UINavigationController *navc = [[UINavigationController alloc] init];
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            navc.navigationBar.tintColor = [UIColor colorWithRed:0.6 green:0 blue:0 alpha:1];
        } else {
            navc.navigationBar.barTintColor = [UIColor colorWithRed:0.6 green:0 blue:0 alpha:1];
            navc.navigationBar.tintColor = [UIColor whiteColor];
            navc.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
            navc.navigationBar.barStyle = UIBarStyleBlack;
        }
        navc.viewControllers = @[[[IHWPreferencesViewController alloc] initWithStyle:UITableViewStyleGrouped], [[IHWNotificationOptionsViewController alloc] initWithStyle:UITableViewStyleGrouped]];
        [self presentViewController:navc animated:YES completion:nil];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"seenNotifications"];
    }
}

- (void)cacheViewControllersAroundDate:(IHWDate *)aroundDate {
    //We can't cache anything if the curriculum isn't loaded
    if (![[IHWCurriculum currentCurriculum] isLoaded]) return;
    NSMutableDictionary *VCs = [NSMutableDictionary dictionary];
    NSDictionary *oldVCs;
    @synchronized(self) {
        //Make sure nobody is modifying loadedviewcontrollers
        oldVCs = [self.loadedViewControllers copy];
    }
    for (IHWDate *date = [aroundDate dateByAddingDays:-2]; [date compare:[aroundDate dateByAddingDays:2]] != NSOrderedDescending; date = [date dateByAddingDays:1]) {
        //For each date, if it is in bounds, either find its viewcontroller in the old loaded viewcontrollers dictionary or create a new one and add it to the new dictionary
        if (![[IHWCurriculum currentCurriculum] dateInBounds:date]) continue;
        if ([oldVCs objectForKey:date] == nil) {
            IHWDayViewController *vc = [[IHWDayViewController alloc] initWithDate:date];
            [VCs setObject:vc forKey:date];
        } else {
            [VCs setObject:[oldVCs objectForKey:date] forKey:date];
        }
    }
    @synchronized(self) {
        //Make sure nobody is modifying loadedviewcontrollers
        [self.loadedViewControllers setDictionary:VCs];
        //NSLog(@"Number of loaded VCs: %d", self.loadedViewControllers.count);
    }
}

- (void)showCourses {
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:[[IHWNormalCoursesViewController alloc] initWithNibName:@"IHWNormalCoursesViewController" bundle:nil]];
    [self presentViewController:navc animated:YES completion:nil];
}

- (void)optionsButtonClicked {
    //Show the preferences view controller inside a new modal uinavigationcontroller
    IHWPreferencesViewController *prefsc = [[IHWPreferencesViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:prefsc];
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        navc.navigationBar.tintColor = [UIColor colorWithRed:0.6 green:0 blue:0 alpha:1];
    } else {
        navc.navigationBar.barTintColor = [UIColor colorWithRed:0.6 green:0 blue:0 alpha:1];
        navc.navigationBar.tintColor = [UIColor whiteColor];
        navc.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
        navc.navigationBar.barStyle = UIBarStyleBlack;
    }
    [self presentViewController:navc animated:YES completion:nil];
}

- (void)refresh {
    self.loadingView = [[IHWLoadingView alloc] initWithText:@"Loading..."];
    //Reload and add self as a loading listener
    [[IHWCurriculum reloadCurrentCurriculum].curriculumLoadingListeners addObject:self];
    [self.pageViewController setViewControllers:[NSArray arrayWithObject:[[UIViewController alloc] init]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (![[IHWCurriculum currentCurriculum] isLoaded]) return nil;
    IHWDate *d = nil;
    if ([viewController isMemberOfClass:[IHWDayViewController class]]) {
        d = [((IHWDayViewController *)viewController).date dateByAddingDays:-1];
    } else {
        d = [IHWDate today];
    }
    @synchronized(self) {
        if ([self.loadedViewControllers objectForKey:d] == nil && [[IHWCurriculum currentCurriculum] dateInBounds:d]) {
            //Create the ViewController if necessary
            IHWDayViewController *vc = [[IHWDayViewController alloc] initWithDate:d];
            [self.loadedViewControllers setObject:vc forKey:d];
            return vc;
        } else {
            //We have it cached -- return it
            return [self.loadedViewControllers objectForKey:d];
        }
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (![[IHWCurriculum currentCurriculum] isLoaded]) return nil;
    IHWDate *d = nil;
    if ([viewController isMemberOfClass:[IHWDayViewController class]]) {
        d = [((IHWDayViewController *)viewController).date dateByAddingDays:1];
    } else {
        d = [IHWDate today];
    }
    @synchronized(self) {
        if ([self.loadedViewControllers objectForKey:d] == nil && [[IHWCurriculum currentCurriculum] dateInBounds:d]) {
            //Create the ViewController if necessary
            UIViewController *vc = [[IHWDayViewController alloc] initWithDate:d];
            [self.loadedViewControllers setObject:vc forKey:d];
            return vc;
        } else {
            //We have it cached -- return it
            UIViewController *result = [self.loadedViewControllers objectForKey:d];
            return result;
        }
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if ([[pageViewController.viewControllers objectAtIndex:0] isKindOfClass:[IHWDayViewController class]]) {
        //Set the current date to the date that just appeared
        self.currentDate = ((IHWDayViewController *)[pageViewController.viewControllers objectAtIndex:0]).date;
        //Cache viewcontrollers around the current date
        if (self.queue.operationCount == 0) [self.queue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(cacheViewControllersAroundDate:) object:self.currentDate]];
    }
}

- (IBAction)goBack:(id)sender {
    //Basically do everything manually
    //Not sure why this is so slow
    IHWDayViewController *current = [self.pageViewController.viewControllers objectAtIndex:0];
    IHWDayViewController *toDisplay = (IHWDayViewController *)[self pageViewController:self.pageViewController viewControllerBeforeViewController:current];
    if (toDisplay == nil) return;
    [self.pageViewController setViewControllers:[NSArray arrayWithObject:toDisplay] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    self.currentDate = toDisplay.date;
    [self pageViewController:self.pageViewController didFinishAnimating:NO previousViewControllers:nil transitionCompleted:NO];
}

- (IBAction)goForward:(id)sender {
    //Basically do everything manually
    //Not sure why this is so slow
    IHWDayViewController *current = [self.pageViewController.viewControllers objectAtIndex:0];
    IHWDayViewController *toDisplay = (IHWDayViewController *)[self pageViewController:self.pageViewController viewControllerAfterViewController:current];
    if (toDisplay == nil) return;
    [self.pageViewController setViewControllers:[NSArray arrayWithObject:toDisplay] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    self.currentDate = toDisplay.date;
    [self pageViewController:self.pageViewController didFinishAnimating:NO previousViewControllers:nil transitionCompleted:NO];
}

- (IBAction)gotoToday:(id)sender {
    IHWDate *today = [IHWDate today];
    [self showDayWithDate:today];
}

- (IBAction)gotoDate:(id)sender {
    //Present Calendar View
    [self presentViewController:_calControl animated:YES completion:nil];
}

- (void)showDayWithDate:(IHWDate *)date {
    //Find which direction to scroll
    UIPageViewControllerNavigationDirection dir;
    if ([self.currentDate daysUntilDate:date] > 0)
        dir = UIPageViewControllerNavigationDirectionForward;
    else if ([self.currentDate daysUntilDate:date] < 0)
        dir = UIPageViewControllerNavigationDirectionReverse;
    else return;
    
    IHWDayViewController *toDisplay;
    @synchronized(self) {
        //Find new viewcontroller in cache or create new on-the-fly
        if ([self.loadedViewControllers objectForKey:date] == nil && [[IHWCurriculum currentCurriculum] dateInBounds:date]) {
            toDisplay = [[IHWDayViewController alloc] initWithDate:date];
            [self.loadedViewControllers setObject:toDisplay forKey:date];
        } else toDisplay = [self.loadedViewControllers objectForKey:date];
    }
    if (toDisplay == nil) return;
    
    __block IHWScheduleViewController *blocksafeSelf = self;
    
    [self.pageViewController setViewControllers:[NSArray arrayWithObject:toDisplay] direction:dir animated:YES completion:^(BOOL finished) {
        //Don't remember why this is necessary
        [blocksafeSelf performSelectorOnMainThread:@selector(displayDayViewController:) withObject:toDisplay waitUntilDone:NO];
    }];
    self.currentDate = date;
    [self pageViewController:self.pageViewController didFinishAnimating:NO previousViewControllers:nil transitionCompleted:NO];
}

- (void)displayDayViewController:(IHWDayViewController *)dayVC {
    //Don't remember why this is necessary
    [self.pageViewController setViewControllers:[NSArray arrayWithObject:dayVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    //sent when date COULD POSSIBLY be displayed (i.e. the user scrolled halfway over)
    //NSLog(@"Will transition to view controller");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)simpleCalendarViewController:(PDTSimpleCalendarViewController *)controller didSelectDate:(NSDate *)date {
    //Dismiss the Calendar View Controller
    [_calControl dismissViewControllerAnimated:YES completion:nil];

    //Create IHWDate from Selected Date
    _selectedDate = date;
    
    //Change iHW Schedule to new date
    [self showDayWithDate:_selectedDate];
}

- (IBAction)finishedSelection:(id)sender {
    [_calControl dismissViewControllerAnimated:YES completion:nil];
}

@end
