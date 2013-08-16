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

@interface IHWScheduleViewController : UIViewController <IHWCurriculumLoadingListener, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UIView *pageContainerView;
@property (strong, nonatomic) IHWLoadingView *loadingView;
@property (strong, nonatomic) IHWDate *currentDate;

@end
