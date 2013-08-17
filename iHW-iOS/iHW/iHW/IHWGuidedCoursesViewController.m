//
//  IHWGuidedCoursesViewController.m
//  iHW
//
//  Created by Jonathan Burns on 8/12/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWGuidedCoursesViewController.h"
#import "IHWScheduleViewController.h"
#import "IHWCurriculum.h"

@implementation IHWGuidedCoursesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveCourses)], [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showNewCourseView)]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)saveCourses {
    [[IHWCurriculum currentCurriculum] saveCourses];
    IHWScheduleViewController *svc = [[IHWScheduleViewController alloc] initWithNibName:@"IHWScheduleViewController" bundle:nil];
    [self.navigationController pushViewController:svc animated:YES];
    [self.navigationController setViewControllers:[NSArray arrayWithObject:svc]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
