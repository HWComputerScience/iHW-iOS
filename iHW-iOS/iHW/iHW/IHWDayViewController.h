//
//  IHWDayViewController.h
//  iHW
//
//  Created by Jonathan Burns on 8/13/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IHWDate.h"
#import "IHWDay.h"
#import "UILabelPadding.h"

@interface IHWDayViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property int headerHeight;
@property (strong, nonatomic) UILabelPadding *dayNameLabel;
@property (strong, nonatomic) UILabelPadding *dayCaptionLabel;
@property (nonatomic, strong) IHWDate *date;
@property (nonatomic, strong) IHWDay *day;
@property (nonatomic, strong) NSMutableArray *cells;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic) BOOL hasUnsavedChanges;
@property int scrollToIndex;
@property UIEdgeInsets originalInsets;

@property (weak, nonatomic) IBOutlet UILabel *weekdayLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *periodsTableView;

- (void)registerKeyboardObservers;
- (id)initWithDate:(IHWDate *)date;
- (void)updateRowHeightAtIndex:(int)index toHeight:(int)height;
- (void)moveCountdownToPeriodAfterPeriodAtIndex:(int)index;

@end
