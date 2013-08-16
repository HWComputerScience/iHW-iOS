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

@interface IHWScheduleViewController ()

@end

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
        if (self.currentDate == nil) self.currentDate = [IHWDate IHWDate];
        [self.pageViewController setViewControllers:[NSArray arrayWithObject:[[IHWDayViewController alloc] initWithDate:self.currentDate]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)curriculumFinishedLoading:(IHWCurriculum *)curriculum {
    [self.loadingView dismiss];
    [curriculum.curriculumLoadingListeners removeObject:self];
    self.loadingView = nil;
    if (self.currentDate == nil) self.currentDate = [IHWDate IHWDate];
    [self.pageViewController setViewControllers:[NSArray arrayWithObject:[[IHWDayViewController alloc] initWithDate:self.currentDate]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void)curriculumFailedToLoad:(IHWCurriculum *)curriculum {
    [self.loadingView dismiss];
    [curriculum.curriculumLoadingListeners removeObject:self];
    self.loadingView = nil;
    [[[UIAlertView alloc] initWithTitle:@"Schedule Currently Unavailable" message:@"Please check your internet connection and try again later." delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[IHWCurriculum currentCurriculum].curriculumLoadingListeners addObject:self];
    [[IHWCurriculum currentCurriculum] loadEverythingWithStartingDate:[IHWDate IHWDate]];
}

- (void)showCourses {
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:[[IHWNormalCoursesViewController alloc] initWithNibName:@"IHWNormalCoursesViewController" bundle:nil]];
    [self presentViewController:navc animated:YES completion:nil];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (![[IHWCurriculum currentCurriculum] isLoaded]) return nil;
    IHWDate *d = nil;
    if ([viewController isMemberOfClass:[IHWDayViewController class]]) d = [((IHWDayViewController *)viewController).date dateByAddingDays:-1];
    else d = [IHWDate IHWDate];
    if ([[IHWCurriculum currentCurriculum] dateInBounds:d]) {
        return [[IHWDayViewController alloc] initWithDate:d];
    }
    else return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (![[IHWCurriculum currentCurriculum] isLoaded]) return nil;
    IHWDate *d = nil;
    if ([viewController isMemberOfClass:[IHWDayViewController class]]) d = [((IHWDayViewController *)viewController).date dateByAddingDays:1];
    else d = [IHWDate IHWDate];
    if ([[IHWCurriculum currentCurriculum] dateInBounds:d]) {
        return [[IHWDayViewController alloc] initWithDate:d];
    }
    else return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if ([[pageViewController.viewControllers objectAtIndex:0] isKindOfClass:[IHWDayViewController class]]) {
        self.currentDate = ((IHWDayViewController *)[pageViewController.viewControllers objectAtIndex:0]).date;
        NSLog(@"Finished displaying date:%@", self.currentDate.description);
    }
}

- (IBAction)goBack:(id)sender {
    IHWDayViewController *toDisplay = (IHWDayViewController *)[self pageViewController:self.pageViewController viewControllerBeforeViewController:[self.pageViewController.viewControllers objectAtIndex:0]];
    [self.pageViewController setViewControllers:[NSArray arrayWithObject:toDisplay] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    self.currentDate = toDisplay.date;
}

- (IBAction)goForward:(id)sender {
    IHWDayViewController *toDisplay = (IHWDayViewController *)[self pageViewController:self.pageViewController viewControllerAfterViewController:[self.pageViewController.viewControllers objectAtIndex:0]];
    [self.pageViewController setViewControllers:[NSArray arrayWithObject:toDisplay] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    self.currentDate = toDisplay.date;
}

- (IBAction)gotoToday:(id)sender {
    IHWDate *today = [IHWDate IHWDate];
    UIPageViewControllerNavigationDirection dir;
    if ([self.currentDate daysUntilDate:today] > 0) dir = UIPageViewControllerNavigationDirectionForward;
    else if ([self.currentDate daysUntilDate:today] < 0) dir = UIPageViewControllerNavigationDirectionReverse;
    else return;
    IHWDayViewController *toDisplay = [[IHWDayViewController alloc] initWithDate:[IHWDate IHWDate]];
    __block IHWScheduleViewController *blocksafeSelf = self;
    [self.pageViewController setViewControllers:[NSArray arrayWithObject:toDisplay] direction:dir animated:YES completion:^(BOOL finished) {
        [blocksafeSelf performSelectorOnMainThread:@selector(displayDayViewController:) withObject:toDisplay waitUntilDone:NO];
    }];
    self.currentDate = today;
}

- (void)displayDayViewController:(IHWDayViewController *)dayVC {
    [self.pageViewController setViewControllers:[NSArray arrayWithObject:dayVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    //sent when date COULD POSSIBLY be displayed
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
