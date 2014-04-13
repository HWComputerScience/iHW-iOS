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
        self.scrollToIndex = -1;
        self.cells = [NSMutableArray array];
        self.originalInsets = UIEdgeInsetsMake(0, 0, 44, 0);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@"viewDidLoad : %@", self.date.description);
    CGRect frame = CGRectMake(0, 0, 320, 48);
    UIView *background = [[UIView alloc] initWithFrame:frame];
    CALayer *solidLayer = [CALayer layer];
    solidLayer.backgroundColor = [UIColor colorWithRed:0.87 green:0.85 blue:0.77 alpha:1].CGColor;
    solidLayer.frame = CGRectMake(0, 0, 5000, 45);
    [background.layer addSublayer:solidLayer];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:0.87 green:0.84 blue:0.74 alpha:1].CGColor, (id)[UIColor colorWithRed:0.87 green:0.86 blue:0.80 alpha:1].CGColor, nil];
        gradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0], [NSNumber numberWithFloat:1], nil];
        gradientLayer.frame = CGRectMake(0, 0, 5000, 45);
        [background.layer addSublayer:gradientLayer];
        
        CAGradientLayer *topShadow = [CAGradientLayer layer];
        topShadow.frame = CGRectMake(0, 45, 5000, 3);
        topShadow.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0 alpha:0.25f] CGColor], (id)[[UIColor clearColor] CGColor], nil];
        [background.layer insertSublayer:topShadow atIndex:0];
    }
    
    background.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:background aboveSubview:self.periodsTableView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[background]|" options:NSLayoutFormatAlignAllLeft metrics:nil views:@{@"background":background}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[background(==height)]" options:NSLayoutFormatAlignAllTop metrics:@{@"height": [NSNumber numberWithFloat:frame.size.height]} views:@{@"background":background}]];
    
    self.weekdayLabel.text = [self.date dayOfWeek:NO];
    self.titleLabel.text = self.day.title;
    self.periodsTableView.delegate = self;
    self.periodsTableView.dataSource = self;
    
    self.periodsTableView.contentInset = self.originalInsets;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.periodsTableView.separatorInset = UIEdgeInsetsZero;
    }
    
    if ([self.day isKindOfClass:[IHWHoliday class]]) {
        self.periodsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    [self loadTableViewCells];
}

- (void)registerKeyboardObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)unregisterKeyboardObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    //NSLog(@"ViewWillAppear");
    [self registerKeyboardObservers];
    [self.view setNeedsLayout];
    [self.view setNeedsDisplay];
}

- (void)loadTableViewCells {
    //NSLog(@"Loading table view");
    NSMutableArray *cells = [NSMutableArray array];
    for (int index=0; index<self.day.periods.count; index++) {
        UITableViewCell *cell = [self createNewCellForIndex:index];
        [cells addObject:cell];
    }
    [cells addObject:[self createNewCellForIndex:-1]];
    [self.cells setArray:cells];
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
        self.periodsTableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, intersection.size.height, 0);
        [self.periodsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.scrollToIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        self.scrollToIndex = -1;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.25 animations:^{
        self.periodsTableView.contentInset = self.originalInsets;
        self.periodsTableView.scrollIndicatorInsets = self.originalInsets;
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
    if (indexPath.row >= self.cells.count) return 72;
    int result = [((IHWPeriodCellView *)[((UITableViewCell *)[self.cells objectAtIndex:indexPath.row]).contentView.subviews objectAtIndex:0]) neededHeight];
    if (result != 0) {
        //NSLog(@"Returned %d", result);
        return result;
    }
    else return 72;
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
    [cell.contentView addSubview:view];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"period%@.%d", self.date.description, (int)indexPath.row]];
    if (cell==nil && indexPath.row < self.cells.count && [self.cells objectAtIndex:indexPath.row] != [NSNull null]) {
        cell = [self.cells objectAtIndex:indexPath.row];
    }
    if (cell==nil) {
        cell = [self createNewCellForIndex:(int)indexPath.row];
    }
    cell.frame = CGRectMake(0, 0, tableView.bounds.size.width, 1000);
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)updateRowHeightAtIndex:(int)index toHeight:(int)height {
    [self.periodsTableView beginUpdates];
    if (index==-1) index = (int)self.cells.count-1;
    UITableViewCell *cell = [self.cells objectAtIndex:index];
    cell.frame = CGRectMake(0, 0, self.periodsTableView.bounds.size.width, height);
    [self.periodsTableView endUpdates];
}

- (void)moveCountdownToPeriodAfterPeriodAtIndex:(int)index {
    if (self.cells.count > index+1) {
        [[((UITableViewCell *)[self.cells objectAtIndex:index+1]).contentView.subviews objectAtIndex:0] createCountdownViewIfNeeded];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self unregisterKeyboardObservers];
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
