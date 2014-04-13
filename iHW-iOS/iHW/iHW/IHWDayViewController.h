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

@interface IHWDayViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UILabel *dayNameLabel;
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
