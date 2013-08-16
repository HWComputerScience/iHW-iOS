//
//  IHWDayViewController.m
//  iHW
//
//  Created by Jonathan Burns on 8/13/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWDayViewController.h"
#import "IHWCurriculum.h"
#import "IHWPeriodCellView.h"
#import "IHWHoliday.h"

@interface IHWDayViewController ()

@end

@implementation IHWDayViewController

- (id)initWithDate:(IHWDate *)date
{
    self = [super initWithNibName:@"IHWDayViewController" bundle:nil];
    if (self) {
        self.date = date;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    self.day = [[IHWCurriculum currentCurriculum] dayWithDate:self.date];
    self.rowHeights = [NSMutableArray array];
    for (int i=0; i<self.day.periods.count; i++) {
        [self.rowHeights addObject:[NSNumber numberWithInt:72]];
    }
    self.weekdayLabel.text = [self.date dayOfWeek:NO];
    self.titleLabel.text = self.day.title;
    if ([self.day isKindOfClass:[IHWHoliday class]]) {
        self.periodsTableView.hidden = YES;
        self.dayNameLabel.hidden = NO;
        self.dayNameLabel.text = ((IHWHoliday *)self.day).name;
    } else {
        self.periodsTableView.delegate = self;
        self.periodsTableView.dataSource = self;
    }
    [self.periodsTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.day.periods.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[self.rowHeights objectAtIndex:indexPath.row] intValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"period"];
    cell.frame = CGRectMake(0, 0, self.view.bounds.size.width, [[self.rowHeights objectAtIndex:indexPath.row] intValue]);
    IHWPeriodCellView *view = [[IHWPeriodCellView alloc] initWithPeriod:[self.day.periods objectAtIndex:indexPath.row] forTableViewCell:cell];
    [cell.contentView addSubview:view];
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
