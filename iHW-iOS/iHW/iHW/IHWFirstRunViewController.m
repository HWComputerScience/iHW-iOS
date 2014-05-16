//
//  IHWFirstRunViewController.m
//  iHW
//
//  Created by Jonathan Burns on 8/11/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWFirstRunViewController.h"
#import "IHWCurriculum.h"
#import "IHWConstants.h"
#import "IHWDownloadScheduleViewController.h"
#import "IHWGuidedCoursesViewController.h"
#import "IHWDate.h"

@interface IHWFirstRunViewController ()

@end

@implementation IHWFirstRunViewController
//This class controls the campus selection and "download or add manually" screens that show when the user first starts using the app.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [IHWCurriculum setCurrentYear:[[IHWDate today] dateByAddingDays:-365/2].year];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backButton.alpha = 0;
    self.methodPromptLabel.alpha = 0;
    self.downloadButton.alpha = 0;
    self.manualButton.alpha = 0;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.topSpaceConstraint.constant = 20;
        self.topSpaceConstraint2.constant = 5;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (IBAction)middleSchoolClicked:(id)sender {
    [IHWCurriculum setCurrentCampus:CAMPUS_MIDDLE];
    [[IHWCurriculum currentCurriculum].curriculumLoadingListeners addObject:self];
    [self gotoStep2];
}

- (IBAction)upperSchoolClicked:(id)sender {
    [IHWCurriculum setCurrentCampus:CAMPUS_UPPER];
    [[IHWCurriculum currentCurriculum].curriculumLoadingListeners addObject:self];
    [self gotoStep2];
}

- (void)gotoStep2 {
    self.downloadButton.hidden = NO;
    self.manualButton.hidden = NO;
    self.backButton.hidden = NO;
    self.methodPromptLabel.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.middleSchoolButton.alpha = 0;
        self.upperSchoolButton.alpha = 0;
        self.backButton.alpha = 1;
        self.downloadButton.alpha = 1;
        self.manualButton.alpha = 1;
        self.methodPromptLabel.alpha = 1;
    } completion:^(BOOL finished) {
        self.middleSchoolButton.hidden = YES;
        self.upperSchoolButton.hidden = YES;
    }];
}

- (IBAction)downloadClicked:(id)sender {
    [self.navigationController pushViewController:[[IHWDownloadScheduleViewController alloc] initWithNibName:@"IHWDownloadScheduleViewController" bundle:nil] animated:YES];
}

- (IBAction)manualClicked:(id)sender {
    [self.navigationController pushViewController:[[IHWGuidedCoursesViewController alloc] initWithNibName:@"IHWGuidedCoursesViewController" bundle:nil] animated:YES];
}

- (IBAction)backButtonClicked:(id)sender {
    self.middleSchoolButton.hidden = NO;
    self.upperSchoolButton.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.backButton.alpha = 0;
        self.downloadButton.alpha = 0;
        self.manualButton.alpha = 0;
        self.methodPromptLabel.alpha = 0;
        self.middleSchoolButton.alpha = 1;
        self.upperSchoolButton.alpha = 1;
    } completion:^(BOOL finished) {
        self.backButton.hidden = YES;
        self.downloadButton.hidden = YES;
        self.manualButton.hidden = YES;
        self.methodPromptLabel.hidden = YES;
    }];
}

- (void)curriculumFailedToLoad:(IHWCurriculum *)curriculum {
    [[[UIAlertView alloc] initWithTitle:@"Schedule Unavailable" message:@"The schedule for the campus and year you selected is not available." delegate:self cancelButtonTitle:@"Back" otherButtonTitles:nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController setViewControllers:@[[[IHWFirstRunViewController alloc] initWithNibName:@"IHWFirstRunViewController" bundle:nil]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
