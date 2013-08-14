//
//  IHWDayViewController.m
//  iHW
//
//  Created by Jonathan Burns on 8/13/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import "IHWDayViewController.h"
#import "IHWCurriculum.h"

@interface IHWDayViewController ()

@end

@implementation IHWDayViewController

- (id)initWithDate:(IHWDate *)date
{
    self = [super initWithNibName:@"IHWDayViewController" bundle:nil];
    if (self) {
        self.date = date;
        self.day = [[IHWCurriculum currentCurriculum] dayWithDate:date];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.weekdayLabel.text = [self.date dayOfWeek:NO];
    self.titleLabel.text = self.day.title;
    NSArray *hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-[view]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:@{@"view":self.view}];
    [self.view.superview addConstraints:hConstraints];
    [self.view.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[view]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:@{@"view":self.view}]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
