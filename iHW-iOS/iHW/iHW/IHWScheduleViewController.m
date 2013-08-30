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
#import "IHWAppDelegate.h"

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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Courses" style:UIBarButtonItemStyleBordered target:self action:@selector(showCourses)];
    
    UIToolbar *tools = [[UIToolbar alloc]
                        initWithFrame:CGRectMake(0,0,64,44)];
    tools.clipsToBounds = NO;
    tools.barStyle = -1;
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"whitegear"] style:UIBarButtonItemStylePlain target:self action:@selector(optionsButtonClicked)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    NSArray *buttons = @[item2, item1];
    [tools setItems:buttons animated:NO];
    UIBarButtonItem *rightButtons = [[UIBarButtonItem alloc] initWithCustomView:tools];
    self.navigationItem.rightBarButtonItem = rightButtons;
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    self.loadedViewControllers = [NSMutableDictionary dictionary];
    self.queue = [[NSOperationQueue alloc] init];
    self.operations = [NSMutableDictionary dictionary];
    [self.pageViewController setViewControllers:[NSArray arrayWithObject:[[UIViewController alloc] init]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self addChildViewController:self.pageViewController];
    
    self.pageViewController.view.frame = self.pageContainerView.bounds;
    [self.pageContainerView addSubview:self.pageViewController.view];
}

- (void)viewWillAppear:(BOOL)animated {
    if (![[IHWCurriculum currentCurriculum] isLoaded]) {
        if (![[IHWCurriculum currentCurriculum].curriculumLoadingListeners containsObject:self])
            [[IHWCurriculum currentCurriculum].curriculumLoadingListeners addObject:self];
        self.loadingView = [[IHWLoadingView alloc] initWithText:@"Loading..."];
    } else {
        if (self.currentDate == nil) self.currentDate = [IHWDate today];
        [self.loadedViewControllers setObject:[[IHWDayViewController alloc] initWithDate:self.currentDate] forKey:self.currentDate];
        [self.pageViewController setViewControllers:[NSArray arrayWithObject:[self.loadedViewControllers objectForKey:self.currentDate]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        if (self.queue.operationCount == 0) [self.queue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(cacheViewControllersAroundDate:) object:self.currentDate]];
    }
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)curriculumFinishedLoading:(IHWCurriculum *)curriculum {
    //NSLog(@"Curriculum finished loading");
    [self.loadingView dismiss];
    [curriculum.curriculumLoadingListeners removeObject:self];
    self.loadingView = nil;
    if (self.currentDate == nil) self.currentDate = [IHWDate today];
    if ([self.currentDate compare:[[IHWDate alloc] initWithMonth:7 day:1 year:[IHWCurriculum currentYear]]] == NSOrderedAscending) {
        self.currentDate = [[IHWDate alloc] initWithMonth:7 day:1 year:[IHWCurriculum currentYear]];
    }
    else if ([self.currentDate compare:[[IHWDate alloc] initWithMonth:7 day:1 year:[IHWCurriculum currentYear]+1]] != NSOrderedAscending) {
        self.currentDate = [[[IHWDate alloc] initWithMonth:7 day:1 year:[IHWCurriculum currentYear]+1] dateByAddingDays:-1];
    }
    [self.loadedViewControllers setObject:[[IHWDayViewController alloc] initWithDate:self.currentDate] forKey:self.currentDate];
    [self.pageViewController setViewControllers:[NSArray arrayWithObject:[self.loadedViewControllers objectForKey:self.currentDate]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    if (self.queue.operationCount == 0) [self.queue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(cacheViewControllersAroundDate:) object:self.currentDate]];
}

- (void)curriculumFailedToLoad:(IHWCurriculum *)curriculum {
    //NSLog(@"Curriculum failed to load");
    [self.loadingView dismiss];
    [curriculum.curriculumLoadingListeners removeObject:self];
    self.loadingView = nil;
    if (self.unavailableAlert == nil) {
        self.unavailableAlert = [[UIAlertView alloc] initWithTitle:@"Schedule Currently Unavailable" message:@"Please check your internet connection and try again later." delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:@"Choose year", nil];
        [self.unavailableAlert show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.unavailableAlert = nil;
    if (buttonIndex == 0) {
        [[IHWCurriculum currentCurriculum].curriculumLoadingListeners addObject:self];
        [[IHWCurriculum currentCurriculum] loadEverythingWithStartingDate:[IHWDate today]];
        self.loadingView = [[IHWLoadingView alloc] initWithText:@"Loading..."];
    } else if (buttonIndex == 1) {
        [self presentViewController:[[IHWPreferencesViewController alloc] initWithNibName:@"IHWPreferencesViewController" bundle:nil] animated:YES completion:nil];
    }
}

- (void)cacheViewControllersAroundDate:(IHWDate *)aroundDate {
    if (![[IHWCurriculum currentCurriculum] isLoaded]) return;
    NSMutableDictionary *VCs = [NSMutableDictionary dictionary];
    NSDictionary *oldVCs;
    @synchronized(self) {
        oldVCs = [self.loadedViewControllers copy];
    }
    for (IHWDate *date = [aroundDate dateByAddingDays:-2]; [date compare:[aroundDate dateByAddingDays:2]] != NSOrderedDescending; date = [date dateByAddingDays:1]) {
        if (![[IHWCurriculum currentCurriculum] dateInBounds:date]) continue;
        if ([oldVCs objectForKey:date] == nil) {
            IHWDayViewController *vc = [[IHWDayViewController alloc] initWithDate:date];
            [VCs setObject:vc forKey:date];
        } else {
            [VCs setObject:[oldVCs objectForKey:date] forKey:date];
        }
    }
    @synchronized(self) {
        [self.loadedViewControllers setDictionary:VCs];
        //NSLog(@"Number of loaded VCs: %d", self.loadedViewControllers.count);
    }
}

- (void)showCourses {
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:[[IHWNormalCoursesViewController alloc] initWithNibName:@"IHWNormalCoursesViewController" bundle:nil]];
    [self presentViewController:navc animated:YES completion:nil];
}

- (void)optionsButtonClicked {
    [self presentViewController:[[IHWPreferencesViewController alloc] initWithNibName:@"IHWPreferencesViewController" bundle:nil] animated:YES completion:nil];
}

- (void)refresh {
    self.loadingView = [[IHWLoadingView alloc] initWithText:@"Loading..."];
    [[IHWCurriculum reloadCurrentCurriculum].curriculumLoadingListeners addObject:self];
    [self.pageViewController setViewControllers:[NSArray arrayWithObject:[[UIViewController alloc] init]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (![[IHWCurriculum currentCurriculum] isLoaded]) return nil;
    IHWDate *d = nil;
    if ([viewController isMemberOfClass:[IHWDayViewController class]]) d = [((IHWDayViewController *)viewController).date dateByAddingDays:-1];
    else d = [IHWDate today];
    @synchronized(self) {
        if ([self.loadedViewControllers objectForKey:d] == nil && [[IHWCurriculum currentCurriculum] dateInBounds:d]) {
            return [[IHWDayViewController alloc] initWithDate:d];
        } else {
            return [self.loadedViewControllers objectForKey:d];
        }
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (![[IHWCurriculum currentCurriculum] isLoaded]) {
        NSLog(@"ERROR: Curriculum not loaded");
        return nil;
    }
    IHWDate *d = nil;
    if ([viewController isMemberOfClass:[IHWDayViewController class]]) d = [((IHWDayViewController *)viewController).date dateByAddingDays:1];
    else d = [IHWDate today];
    @synchronized(self) {
        if ([self.loadedViewControllers objectForKey:d] == nil && [[IHWCurriculum currentCurriculum] dateInBounds:d]) {
            UIViewController *result = [[IHWDayViewController alloc] initWithDate:d];
            //NSLog(@"VC (just made): %@", result);
            return result;
        } else {
            UIViewController *result = [self.loadedViewControllers objectForKey:d];
            //NSLog(@"VC (from cache): %@", result);
            return result;
        }
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if ([[pageViewController.viewControllers objectAtIndex:0] isKindOfClass:[IHWDayViewController class]]) {
        self.currentDate = ((IHWDayViewController *)[pageViewController.viewControllers objectAtIndex:0]).date;
        if (self.queue.operationCount == 0) [self.queue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(cacheViewControllersAroundDate:) object:self.currentDate]];
        //NSLog(@"Finished displaying date:%@", self.currentDate.description);
    }
}

- (IBAction)goBack:(id)sender {
    IHWDayViewController *current = [self.pageViewController.viewControllers objectAtIndex:0];
    IHWDayViewController *toDisplay = (IHWDayViewController *)[self pageViewController:self.pageViewController viewControllerBeforeViewController:current];
    if (toDisplay == nil) return;
    [self.pageViewController setViewControllers:[NSArray arrayWithObject:toDisplay] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    self.currentDate = toDisplay.date;
    [self pageViewController:self.pageViewController didFinishAnimating:NO previousViewControllers:nil transitionCompleted:NO];
}

- (IBAction)goForward:(id)sender {
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
    ActionSheetDatePicker *picker = [[ActionSheetDatePicker alloc] initWithTitle:@"Choose a date:" datePickerMode:UIDatePickerModeDate selectedDate:self.currentDate target:self action:@selector(showDayWithDate:) origin:self.toolbar];
    picker.doneButtonText = @"Go";
    [picker showActionSheetPicker];
}

- (void)showDayWithDate:(IHWDate *)date {
    UIPageViewControllerNavigationDirection dir;
    if ([self.currentDate daysUntilDate:date] > 0) dir = UIPageViewControllerNavigationDirectionForward;
    else if ([self.currentDate daysUntilDate:date] < 0) dir = UIPageViewControllerNavigationDirectionReverse;
    else return;
    IHWDayViewController *toDisplay;
    @synchronized(self) {
        if ([self.loadedViewControllers objectForKey:date] == nil && [[IHWCurriculum currentCurriculum] dateInBounds:date]) {
            toDisplay = [[IHWDayViewController alloc] initWithDate:date];
        } else toDisplay = [self.loadedViewControllers objectForKey:date];
    }
    if (toDisplay == nil) return;
    __block IHWScheduleViewController *blocksafeSelf = self;
    [self.pageViewController setViewControllers:[NSArray arrayWithObject:toDisplay] direction:dir animated:YES completion:^(BOOL finished) {
        [blocksafeSelf performSelectorOnMainThread:@selector(displayDayViewController:) withObject:toDisplay waitUntilDone:NO];
    }];
    self.currentDate = date;
    [self pageViewController:self.pageViewController didFinishAnimating:NO previousViewControllers:nil transitionCompleted:NO];
}

- (void)displayDayViewController:(IHWDayViewController *)dayVC {
    [self.pageViewController setViewControllers:[NSArray arrayWithObject:dayVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    //sent when date COULD POSSIBLY be displayed
    //NSLog(@"Will transition to view controller");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
