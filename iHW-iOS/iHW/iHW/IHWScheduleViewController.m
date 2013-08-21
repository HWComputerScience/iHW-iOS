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

@implementation IHWScheduleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"iHW for iOS";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Courses" style:UIBarButtonItemStyleBordered target:self action:@selector(showCourses)];
    
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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    if (![[IHWCurriculum currentCurriculum] isLoaded]) {
        [[IHWCurriculum currentCurriculum].curriculumLoadingListeners addObject:self];
        self.loadingView = [[IHWLoadingView alloc] initWithText:@"Loading..."];
    } else {
        if (self.currentDate == nil) self.currentDate = [IHWDate today];
        [self.loadedViewControllers setObject:[[IHWDayViewController alloc] initWithDate:self.currentDate] forKey:self.currentDate];
        [self.pageViewController setViewControllers:[NSArray arrayWithObject:[self.loadedViewControllers objectForKey:self.currentDate]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        [self cacheViewControllersAroundDate:self.currentDate];
    }
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)curriculumFinishedLoading:(IHWCurriculum *)curriculum {
    [self.loadingView dismiss];
    [curriculum.curriculumLoadingListeners removeObject:self];
    self.loadingView = nil;
    if (self.currentDate == nil) self.currentDate = [IHWDate today];
    [self.loadedViewControllers setObject:[[IHWDayViewController alloc] initWithDate:self.currentDate] forKey:self.currentDate];
    [self.pageViewController setViewControllers:[NSArray arrayWithObject:[self.loadedViewControllers objectForKey:self.currentDate]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self cacheViewControllersAroundDate:self.currentDate];
}

- (void)curriculumFailedToLoad:(IHWCurriculum *)curriculum {
    [self.loadingView dismiss];
    [curriculum.curriculumLoadingListeners removeObject:self];
    self.loadingView = nil;
    [[[UIAlertView alloc] initWithTitle:@"Schedule Currently Unavailable" message:@"Please check your internet connection and try again later." delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[IHWCurriculum currentCurriculum].curriculumLoadingListeners addObject:self];
    [[IHWCurriculum currentCurriculum] loadEverythingWithStartingDate:[IHWDate today]];
    self.loadingView = [[IHWLoadingView alloc] initWithText:@"Loading..."];
}

- (void)cacheViewControllersAroundDate:(IHWDate *)aroundDate {
    if (![[IHWCurriculum currentCurriculum] isLoaded]) return;
    NSMutableDictionary *VCs = [NSMutableDictionary dictionary];
    [self.queue addOperationWithBlock:^{
        [self.queue setSuspended:YES];
        for (IHWDate *date = [aroundDate dateByAddingDays:-2]; [date compare:[aroundDate dateByAddingDays:2]] != NSOrderedDescending; date = [date dateByAddingDays:1]) {
            if (![[IHWCurriculum currentCurriculum] dateInBounds:date]) continue;
            if ([self.loadedViewControllers objectForKey:date] == nil && [self.operations objectForKey:date] == nil) {
                NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                    IHWDayViewController *vc = [[IHWDayViewController alloc] initWithDate:date];
                    [self performSelectorOnMainThread:@selector(addLoadedDayViewController:) withObject:vc waitUntilDone:YES];
                }];
                [self.operations setObject:operation forKey:date];
                [self.queue addOperation:operation];
            } else if ([self.loadedViewControllers objectForKey:date] != nil) {
                [VCs setObject:[self.loadedViewControllers objectForKey:date] forKey:date];
            }
        }
        [self.loadedViewControllers setDictionary:VCs];
        [self.queue setSuspended:NO];
    }];
    //NSLog(@"Number of loaded VCs: %d", self.loadedViewControllers.count);
}

- (void)addLoadedDayViewController:(IHWDayViewController *)vc {
    [self.loadedViewControllers setObject:vc forKey:vc.date];
}

- (void)showCourses {
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:[[IHWNormalCoursesViewController alloc] initWithNibName:@"IHWNormalCoursesViewController" bundle:nil]];
    [self presentViewController:navc animated:YES completion:nil];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (![[IHWCurriculum currentCurriculum] isLoaded]) return nil;
    IHWDate *d = nil;
    if ([viewController isMemberOfClass:[IHWDayViewController class]]) d = [((IHWDayViewController *)viewController).date dateByAddingDays:-1];
    else d = [IHWDate today];
    if ([self.loadedViewControllers objectForKey:d] == nil && [[IHWCurriculum currentCurriculum] dateInBounds:d]) {
        return [[IHWDayViewController alloc] initWithDate:d];
    } else return [self.loadedViewControllers objectForKey:d];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (![[IHWCurriculum currentCurriculum] isLoaded]) return nil;
    IHWDate *d = nil;
    if ([viewController isMemberOfClass:[IHWDayViewController class]]) d = [((IHWDayViewController *)viewController).date dateByAddingDays:1];
    else d = [IHWDate today];
    if ([self.loadedViewControllers objectForKey:d] == nil && [[IHWCurriculum currentCurriculum] dateInBounds:d]) {
        return [[IHWDayViewController alloc] initWithDate:d];
    } else return [self.loadedViewControllers objectForKey:d];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if ([[pageViewController.viewControllers objectAtIndex:0] isKindOfClass:[IHWDayViewController class]]) {
        self.currentDate = ((IHWDayViewController *)[pageViewController.viewControllers objectAtIndex:0]).date;
        [self cacheViewControllersAroundDate:self.currentDate];
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
    if ([self.loadedViewControllers objectForKey:date] == nil && [[IHWCurriculum currentCurriculum] dateInBounds:date]) {
        toDisplay = [[IHWDayViewController alloc] initWithDate:date];
    } else toDisplay = [self.loadedViewControllers objectForKey:date];
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
