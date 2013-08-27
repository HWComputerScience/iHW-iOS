//
//  IHWPreferencesViewController.m
//  iHW
//
//  Created by Jonathan Burns on 8/21/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWPreferencesViewController.h"
#import "IHWCurriculum.h"
#import "IHWAppDelegate.h"
#import "IHWDownloadScheduleViewController.h"
#import "IHWScheduleViewController.h"

@interface IHWPreferencesViewController ()

@end

@implementation IHWPreferencesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.yearField.text = [NSString stringWithFormat:@"%d", [IHWCurriculum currentYear]];
    [self.yearField addTarget:self action:@selector(yearFieldChanged:) forControlEvents:UIControlEventAllEditingEvents];
    [self yearFieldChanged:nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)yearFieldChanged:(id)sender {
    int year = self.yearField.text.intValue;
    if (year != 0) {
        self.yearHintField.text = [NSString stringWithFormat:@"- %02d", (year+1)%100];
    }
}

- (IBAction)setYearButtonClicked:(id)sender {
    int year = self.yearField.text.intValue;
    if (year != 0) [IHWCurriculum setCurrentYear:year];
    else self.yearField.text = [NSString stringWithFormat:@"%d", [IHWCurriculum currentYear]];
    [((IHWAppDelegate *)[[UIApplication sharedApplication] delegate]).navController setViewControllers:@[[[IHWScheduleViewController alloc] initWithNibName:@"IHWScheduleViewController" bundle:nil]] animated:NO];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)redownloadButtonClicked:(id)sender {
    [((IHWAppDelegate *)[[UIApplication sharedApplication] delegate]).navController setViewControllers:@[[[IHWDownloadScheduleViewController alloc] initWithNibName:@"IHWDownloadScheduleViewController" bundle:nil]] animated:NO];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)middleSchoolClicked:(id)sender {
    [IHWCurriculum setCurrentCampus:CAMPUS_MIDDLE];
    [((IHWAppDelegate *)[[UIApplication sharedApplication] delegate]).navController setViewControllers:@[[[IHWScheduleViewController alloc] initWithNibName:@"IHWScheduleViewController" bundle:nil]] animated:NO];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)upperSchoolClicked:(id)sender {
    [IHWCurriculum setCurrentCampus:CAMPUS_UPPER];
    [((IHWAppDelegate *)[[UIApplication sharedApplication] delegate]).navController setViewControllers:@[[[IHWScheduleViewController alloc] initWithNibName:@"IHWScheduleViewController" bundle:nil]] animated:NO];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)closeButtonClicked:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
