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

@implementation IHWPreferencesViewController {
    NSCharacterSet *nonnumericSet;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.navigationItem.title = @"iHW Options";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(closeOptions)];
        self.navigationItem.leftBarButtonItem.tintColor = nil;
        nonnumericSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.yearField.delegate = self;
    self.yearField.text = [NSString stringWithFormat:@"%d", [IHWCurriculum currentYear]];
    [self.yearField addTarget:self action:@selector(yearFieldChanged:) forControlEvents:UIControlEventAllEditingEvents];
    [self yearFieldChanged:nil];
    self.disclaimerView.contentInset = UIEdgeInsetsZero;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.6 green:0 blue:0 alpha:1];
    } else {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.6 green:0 blue:0 alpha:1];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    }
    // Do any additional setup after loading the view from its nib.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *result = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (result.length > 4) return NO;
    if ([result rangeOfCharacterFromSet:nonnumericSet].location != NSNotFound) return NO;
    return YES;
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

- (void)closeOptions {
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
