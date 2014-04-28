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
        self.headerHeight = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Set up the beige background for the weekday and title views
    CGRect frame = CGRectMake(0, 0, 320, 48);
    UIView *background = [[UIView alloc] initWithFrame:frame];
    CALayer *solidLayer = [CALayer layer];
    solidLayer.backgroundColor = [UIColor colorWithRed:0.87 green:0.85 blue:0.77 alpha:1].CGColor;
    solidLayer.frame = CGRectMake(0, 0, 5000, 45);
    [background.layer addSublayer:solidLayer];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        //Only add a gradient to the background view in iOS 6 or earlier
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:0.87 green:0.84 blue:0.74 alpha:1].CGColor, (id)[UIColor colorWithRed:0.87 green:0.86 blue:0.80 alpha:1].CGColor, nil];
        gradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0], [NSNumber numberWithFloat:1], nil];
        gradientLayer.frame = CGRectMake(0, 0, 5000, 45);
        [background.layer addSublayer:gradientLayer];
        
        //Only add a shadow to the background view in iOS 6 or earlier
        CAGradientLayer *topShadow = [CAGradientLayer layer];
        topShadow.frame = CGRectMake(0, 45, 5000, 3);
        topShadow.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0 alpha:0.25f] CGColor], (id)[[UIColor clearColor] CGColor], nil];
        [background.layer insertSublayer:topShadow atIndex:0];
    }
    background.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:background aboveSubview:self.periodsTableView];
    
    //Set up auto layout
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[background]|" options:NSLayoutFormatAlignAllLeft metrics:nil views:@{@"background":background}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[background(==height)]" options:NSLayoutFormatAlignAllTop metrics:@{@"height": [NSNumber numberWithFloat:frame.size.height]} views:@{@"background":background}]];
    
    //Add text to labels
    self.weekdayLabel.text = [self.date dayOfWeek:NO];
    self.titleLabel.text = self.day.title;
    
    self.periodsTableView.delegate = self;
    self.periodsTableView.dataSource = self;
    
    //fix for translucent nav bar in iOS 7
    self.periodsTableView.contentInset = self.originalInsets;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.periodsTableView.separatorInset = UIEdgeInsetsZero;
    }
    
    //remove horizontal lines for holidays
    if ([self.day isKindOfClass:[IHWHoliday class]]) {
        self.periodsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    [self loadTableViewCells];
    
    //Set up holiday title
    if ([self.day isKindOfClass:[IHWHoliday class]] && ![((IHWHoliday*)self.day).name isEqualToString:@""]) {
        UIFont *font = [UIFont systemFontOfSize:30];
        CGSize textSize = [((IHWHoliday*)self.day).name sizeWithFont:font constrainedToSize:CGSizeMake(self.periodsTableView.bounds.size.width-4, self.periodsTableView.bounds.size.height)];
        
        self.dayNameLabel = [[UILabelPadding alloc] initWithFrame:CGRectMake(0, self.headerHeight, self.periodsTableView.bounds.size.width, textSize.height+4)];
        self.dayCaptionLabel.edgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
        self.dayNameLabel.numberOfLines = textSize.height / font.lineHeight;
        self.dayNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.dayNameLabel.font = font;
        self.dayNameLabel.textAlignment = NSTextAlignmentCenter;
        self.dayNameLabel.text = ((IHWHoliday *)self.day).name;
        self.dayNameLabel.layer.backgroundColor = [[UIColor whiteColor] CGColor];
        
        CALayer *border = [CALayer layer];
        border.backgroundColor = [self.periodsTableView.separatorColor CGColor];
        border.frame = CGRectMake(0, self.dayNameLabel.frame.size.height-1, self.periodsTableView.bounds.size.width, 1);
        [self.dayNameLabel.layer addSublayer:border];
        self.headerHeight += textSize.height+4;
    }
    
    //Set up day caption
    if (self.day.caption != nil && ![self.day.caption isEqualToString:@""]) {
        UIFont *font = [UIFont systemFontOfSize:17];
        CGSize textSize = [self.day.caption sizeWithFont:font constrainedToSize:CGSizeMake(self.periodsTableView.bounds.size.width-4, self.periodsTableView.bounds.size.height)];
        
        self.dayCaptionLabel = [[UILabelPadding alloc] initWithFrame:CGRectMake(0, self.headerHeight, self.periodsTableView.bounds.size.width, textSize.height+4)];
        self.dayCaptionLabel.edgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
        self.dayCaptionLabel.numberOfLines = textSize.height / font.lineHeight;
        self.dayCaptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.dayCaptionLabel.font = font;
        self.dayCaptionLabel.textAlignment = NSTextAlignmentLeft;
        self.dayCaptionLabel.text = self.day.caption;
        self.dayCaptionLabel.backgroundColor = [UIColor colorWithRed:1 green:.78 blue:.34 alpha:1];
        self.dayCaptionLabel.layer.backgroundColor = [[UIColor colorWithRed:1 green:.78 blue:.34 alpha:1] CGColor];
        
        CALayer *border = [CALayer layer];
        border.backgroundColor = [self.periodsTableView.separatorColor CGColor];
        border.frame = CGRectMake(0, self.dayCaptionLabel.frame.size.height-1, self.periodsTableView.bounds.size.width, 1);
        [self.dayCaptionLabel.layer addSublayer:border];
        self.headerHeight += textSize.height+4;
    }
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
    if (self.scrollToIndex != -1) {
        [self.periodsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.scrollToIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        self.scrollToIndex = -1;
    }
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
    /*if ([self.day isKindOfClass:[IHWHoliday class]] && ![((IHWHoliday*)self.day).name isEqualToString:@""]) return 64;
    return 0;*/
    return self.headerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.periodsTableView.bounds.size.width, self.headerHeight)];
    if (self.dayNameLabel != nil) {
        [headerView addSubview:self.dayNameLabel];
    }
    if (self.dayCaptionLabel != nil) {
        [headerView addSubview:self.dayCaptionLabel];
        
        if (self.day.captionLink != nil && ![self.day.captionLink isEqualToString:@""]) {
            [headerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(captionTapped)]];
            CALayer *imageLayer = [CALayer layer];
            imageLayer.frame = CGRectMake(self.dayCaptionLabel.bounds.size.width-20, self.dayCaptionLabel.bounds.size.height-20, 16, 16);
            UIImage *img = [UIImage imageNamed:@"link"];
            imageLayer.contents = (id)img.CGImage;
            [self.dayCaptionLabel.layer addSublayer:imageLayer];
        }
    }
    return headerView;
}

- (void)captionTapped {
    if (self.day.captionLink != nil && ![self.day.captionLink isEqualToString:@""]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.day.captionLink]];
    }
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
    if (index == -1) {
        //Last cell should be an "additional notes" period
        view = [[IHWPeriodCellView alloc] initWithAdditionalNotesOnDate:self.date withFrame:cell.bounds onHoliday:[self.day isKindOfClass:[IHWHoliday class]]];
    } else {
        //Otherwise make a cell for the period of index `index`
        view = [[IHWPeriodCellView alloc] initWithPeriod:[self.day.periods objectAtIndex:index] atIndex:index forTableViewCell:cell];
    }
    
    cell.frame = CGRectMake(0, 0, self.view.bounds.size.width, [view neededHeight]);
    view.dayViewController = self;
    if ([view createCountdownViewIfNeeded]) self.scrollToIndex = index;
    [cell.contentView addSubview:view];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //first try to reuse a cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"period%@.%d", self.date.description, (int)indexPath.row]];
    //then try to find the cell is in the array
    if (cell==nil && indexPath.row < self.cells.count && [self.cells objectAtIndex:indexPath.row] != [NSNull null]) {
        cell = [self.cells objectAtIndex:indexPath.row];
    }
    //finally create a new one if we can't find one anywhere else
    if (cell==nil) {
        cell = [self createNewCellForIndex:(int)indexPath.row];
    }
    cell.frame = CGRectMake(0, 0, tableView.bounds.size.width, 1000);
    return cell;
}

//disable selecting cells (disable turning blue)
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)updateRowHeightAtIndex:(int)index toHeight:(int)height {
    [self.periodsTableView beginUpdates];
    //allow negative indices for counting from end
    if (index < 0) index = (int)self.cells.count+index;
    if (index < 0) return;
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
