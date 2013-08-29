//
//  IHWPeriodCellView.h
//  iHW
//
//  Created by Jonathan Burns on 8/14/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IHWPeriod.h"
#import "IHWDayViewController.h"

@interface IHWPeriodCellView : UIView <UITextFieldDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) IHWPeriod *period;
@property (nonatomic) int index;
@property (nonatomic, weak) IHWDayViewController *dayViewController;

@property (nonatomic, strong) UILabel *startLabel;
@property (nonatomic, strong) UILabel *endLabel;
@property (nonatomic, strong) UILabel *periodLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *notesView;
@property (nonatomic, strong) UIView *countdownView;
@property (nonatomic, strong) NSTimer *countdownTimer;

- (id)initWithPeriod:(IHWPeriod *)period atIndex:(int)index forTableViewCell:(UITableViewCell *)cell;
- (id)initWithAdditionalNotesOnDate:(IHWDate *)date withFrame:(CGRect)frame onHoliday:(BOOL)holiday;
- (void)createCountdownViewIfNeeded;
- (void)reLayoutViews:(BOOL)animated;
- (void)noteViewChangedAtIndex:(int)index;
- (void)saveNotes;
- (int)neededHeight;

@end
