//
//  IHWDayViewController.m
//  iHW
//
//  Created by Jonathan Burns on 8/13/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "IHWDayViewController.h"
#import "IHWCurriculum.h"
#import "IHWPeriodCellView.h"
#import "IHWHoliday.h"
#import "UIViewController+IHW.h"

@implementation IHWDayViewController

- (id)initWithDate:(IHWDate *)date
{
    self = [super initWithNibName:@"IHWDayViewController" bundle:nil];
    if (self) {
        self.date = date;
        //NSLog(@"init: %@", self.date.description);
        self.day = [[IHWCurriculum currentCurriculum] dayWithDate:self.date];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
        self.scrollToIndex = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@"viewDidLoad : %@", self.date.description);
    CGRect frame = CGRectMake(0, 0, 320, 48);
    UIView *background = [[UIView alloc] initWithFrame:frame];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:0.87 green:0.84 blue:0.74 alpha:1].CGColor, (id)[UIColor colorWithRed:0.87 green:0.86 blue:0.80 alpha:1].CGColor, nil];
    gradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0], [NSNumber numberWithFloat:1], nil];
    gradientLayer.frame = CGRectMake(0, 0, 5000, 45);
    [background.layer addSublayer:gradientLayer];
    
    CAGradientLayer *topShadow = [CAGradientLayer layer];
    topShadow.frame = CGRectMake(0, 45, 5000, 3);
    topShadow.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0 alpha:0.25f] CGColor], (id)[[UIColor clearColor] CGColor], nil];
    [background.layer insertSublayer:topShadow atIndex:0];
    
    background.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:background aboveSubview:self.periodsTableView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[background]|" options:NSLayoutFormatAlignAllLeft metrics:nil views:@{@"background":background}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[background(==height)]" options:NSLayoutFormatAlignAllTop metrics:@{@"height": [NSNumber numberWithFloat:frame.size.height]} views:@{@"background":background}]];
    [self loadTableView:NO];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == 0)
        [self loadTableView:YES];
}

- (void)loadTableView:(BOOL)animated {
    //NSLog(@"Loading table view");
    if (animated) self.periodsTableView.alpha = 0;
    self.cells = [NSMutableArray array];
    for (int index=0; index<self.day.periods.count; index++) {
        UITableViewCell *cell = [self createNewCellForIndex:index];
        [self.cells addObject:cell];
    }
    [self.cells addObject:[self createNewCellForIndex:-1]];
    
    self.weekdayLabel.text = [self.date dayOfWeek:NO];
    self.titleLabel.text = self.day.title;
    self.periodsTableView.delegate = self;
    self.periodsTableView.dataSource = self;
    if ([self.day isKindOfClass:[IHWHoliday class]]) {
        self.periodsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    if (animated) [UIView animateWithDuration:0.25 animations:^{
        self.periodsTableView.alpha = 1;
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    //NSLog(@"viewWillAppear");
    [self.view setNeedsDisplay];
}

- (void)viewDidAppear:(BOOL)animated {
   //NSLog(@"viewDidAppear");
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [self.view convertRect:[aValue CGRectValue] fromView:nil];
    CGRect intersection = CGRectIntersection(keyboardRect, self.periodsTableView.frame);
    [UIView animateWithDuration:0.2 animations:^{
    self.periodsTableView.contentInset = UIEdgeInsetsMake(0, 0, intersection.size.height, 0);
        [self.periodsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.scrollToIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        self.scrollToIndex = -1;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.25 animations:^{
        self.periodsTableView.contentInset = UIEdgeInsetsZero;
    }];    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self.day isKindOfClass:[IHWHoliday class]] && ![((IHWHoliday*)self.day).name isEqualToString:@""]) return 64;
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (![self.day isKindOfClass:[IHWHoliday class]]) return nil;
    self.dayNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.periodsTableView.bounds.size.width, 64)];
    self.dayNameLabel.numberOfLines = 2;
    self.dayNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.dayNameLabel.font = [UIFont systemFontOfSize:25];
    self.dayNameLabel.textAlignment = NSTextAlignmentCenter;
    self.dayNameLabel.text = ((IHWHoliday *)self.day).name;
    
    CALayer *border = [CALayer layer];
    border.backgroundColor = [self.periodsTableView.separatorColor CGColor];
    border.frame = CGRectMake(0, 63, self.periodsTableView.bounds.size.width, 1);
    [self.dayNameLabel.layer addSublayer:border];
    
    return self.dayNameLabel;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cells.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"height at index %d was requested", indexPath.row);
    /*if (indexPath.row >= self.cells.count || [self.cells objectAtIndex:indexPath.row] == [NSNull null]) {
        UITableViewCell *cell = [self createNewCellForIndex:indexPath.row];
        while (self.cells.count < indexPath.row) {
            [self.cells addObject:[NSNull null]];
        }
        [self.cells setObject:cell atIndexedSubscript:indexPath.row];
    }*/
    if (indexPath.row >= self.cells.count) return 72;
    return [((IHWPeriodCellView *)[((UITableViewCell *)[self.cells objectAtIndex:indexPath.row]).contentView.subviews objectAtIndex:0]) neededHeight];
}

- (UITableViewCell *)createNewCellForIndex:(int)index {
    //NSLog(@"Creating cell at index %d", index);
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"period%@.%d", self.date.description, index]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    IHWPeriodCellView *view;
    if (index == -1) view = [[IHWPeriodCellView alloc] initWithAdditionalNotesOnDate:self.date withFrame:cell.bounds onHoliday:[self.day isKindOfClass:[IHWHoliday class]]];
    else view = [[IHWPeriodCellView alloc] initWithPeriod:[self.day.periods objectAtIndex:index] atIndex:index forTableViewCell:cell];
    cell.frame = CGRectMake(0, 0, self.view.bounds.size.width, [view neededHeight]);
    view.dayViewController = self;
    [view createCountdownViewIfNeeded];
    //[self.rowHeights setObject:[NSNumber numberWithFloat:[view neededHeight]] atIndexedSubscript:index];
    [cell.contentView addSubview:view];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"period%@.%d", self.date.description, indexPath.row]];
    if (cell==nil && indexPath.row < self.cells.count && [self.cells objectAtIndex:indexPath.row] != [NSNull null]) {
        cell = [self.cells objectAtIndex:indexPath.row];
    }
    if (cell==nil) {
        cell = [self createNewCellForIndex:indexPath.row];
    }
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)updateRowHeightAtIndex:(int)index toHeight:(int)height {
    [self.periodsTableView beginUpdates];
    //[self.rowHeights setObject:[NSNumber numberWithInt:height] atIndexedSubscript:index];
    //[self.periodsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.periodsTableView endUpdates];
}

- (void)moveCountdownToPeriodAfterPeriodAtIndex:(int)index {
    if (self.cells.count > index+1) {
        [[((UITableViewCell *)[self.cells objectAtIndex:index+1]).contentView.subviews objectAtIndex:0] createCountdownViewIfNeeded];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.hasUnsavedChanges) {
        //NSLog(@"Committing changes");
        [[IHWCurriculum currentCurriculum] saveWeekWithDate:self.date];
        self.hasUnsavedChanges = NO;
    }
}

- (void)applicationDidEnterBackground {
    [super applicationDidEnterBackground];
    if (self.hasUnsavedChanges) {
        //NSLog(@"Committing changes");
        [[IHWCurriculum currentCurriculum] saveWeekWithDate:self.date];
        self.hasUnsavedChanges = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
