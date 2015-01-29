//
//  IHWScheduleViewController.h
//  iHW
//
//  Created by Jonathan Burns on 8/12/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IHWCurriculum.h"
#import "IHWLoadingView.h"
#import "IHWDate.h"
#import <PDTSimpleCalendar/PDTSimpleCalendar.h>

@interface IHWScheduleViewController : UIViewController <IHWCurriculumLoadingListener, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIAlertViewDelegate, PDTSimpleCalendarViewDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UIView *pageContainerView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong) NSMutableDictionary *loadedViewControllers;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) IHWLoadingView *loadingView;
@property (strong, nonatomic) IHWDate *currentDate;
@property (strong, nonatomic) UIAlertView *unavailableAlert;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpaceConstraint;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *todayItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *gotoDateItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardItem;

@property (strong, nonatomic) PDTSimpleCalendarViewController *calendar;
@property (strong, nonatomic) IHWDate *selectedDate;
@property (strong, nonatomic) UINavigationController *calControl;

/**
 *  Tells the delegate that a date was selected by the user.
 *
 *  @param controller the calendarView Controller
 *  @param date       the date being selected (Midnight GMT).
 */
- (void)simpleCalendarViewController:(PDTSimpleCalendarViewController *)controller didSelectDate:(NSDate *)date;

@end
