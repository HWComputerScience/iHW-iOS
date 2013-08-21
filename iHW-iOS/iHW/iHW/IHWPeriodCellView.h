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
#define NOTE_HEIGHT 24

@interface IHWPeriodCellView : UIView <UITextFieldDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) IHWPeriod *period;
@property (nonatomic) int index;
@property (nonatomic, weak) IHWDayViewController *dayViewController;

@property (nonatomic, strong) UILabel *startLabel;
@property (nonatomic, strong) UILabel *endLabel;
@property (nonatomic, strong) UILabel *periodLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *notesView;

- (id)initWithPeriod:(IHWPeriod *)period atIndex:(int)index forTableViewCell:(UITableViewCell *)cell;
- (id)initWithAdditionalNotesOnDate:(IHWDate *)date withFrame:(CGRect)frame onHoliday:(BOOL)holiday;
- (void)saveNotes;
- (int)neededHeight;

@end
