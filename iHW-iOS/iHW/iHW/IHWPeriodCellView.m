//
//  IHWPeriodCellView.m
//  iHW
//
//  Created by Jonathan Burns on 8/14/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWPeriodCellView.h"
#import "IHWUtils.h"
#import "IHWNote.h"
#import "IHWNoteView.h"
#import "IHWAppDelegate.h"
#import "IHWScheduleViewController.h"
#import "IHWDate.h"
#import <QuartzCore/QuartzCore.h>

@implementation IHWPeriodCellView

- (id)initWithPeriod:(IHWPeriod *)period atIndex:(int)index forTableViewCell:(UITableViewCell *)cell;
{
    self = [super initWithFrame:cell.contentView.bounds];
    if (self) {
        self.period = period;
        self.index = index;
        
        self.startLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 3, 68, 19)];
        self.periodLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 22, 68, 30)];
        self.endLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 52, 68, 19)];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(76, 3, 100, 19)];
        self.notesView = [[UIView alloc] initWithFrame:CGRectMake(76, 22, 100, 49)];
        
        self.startLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.periodLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.endLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.notesView.translatesAutoresizingMaskIntoConstraints = NO;
        self.clipsToBounds = YES;
                
        self.startLabel.font = [UIFont systemFontOfSize:17];
        self.periodLabel.font = [UIFont boldSystemFontOfSize:25];
        self.endLabel.font = [UIFont systemFontOfSize:17];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        
        self.startLabel.text = self.period.startTime.description12;
        if (self.period.periodNum != 0)
            self.periodLabel.text = getOrdinal(self.period.periodNum);
        else self.periodLabel.hidden = YES;
        self.endLabel.text = self.period.endTime.description12;
        self.titleLabel.text = self.period.name;
        
        [self addSubview:self.startLabel];
        [self addSubview:self.periodLabel];
        [self addSubview:self.endLabel];
        [self addSubview:self.titleLabel];
        [self addSubview:self.notesView];
        
        for (IHWNote *note in self.period.notes) {
            [self addNoteView:note animated:NO];
        }
        [self addNoteView:nil animated:NO];
    }
    return self;
}

- (id)initWithAdditionalNotesOnDate:(IHWDate *)date withFrame:(CGRect)frame onHoliday:(BOOL)holiday {
    self = [super initWithFrame:frame];
    if (self) {
        self.index = -1;
        self.period = [[IHWPeriod alloc] initWithName:@"Additional Notes" date:date start:[[IHWTime alloc] initWithHour:0 andMinute:0] end:[[IHWTime alloc] initWithHour:0 andMinute:0] number:0 index:self.index];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 3, self.bounds.size.width-8, 19)];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        if (holiday) self.titleLabel.text = @"Notes";
        else self.titleLabel.text = @"Additional Notes";
        [self addSubview:self.titleLabel];
        
        self.notesView = [[UIView alloc] initWithFrame:CGRectMake(4, 22, self.bounds.size.width-8, 49)];
        self.notesView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.notesView];
        
        for (IHWNote *note in self.period.notes) {
            [self addNoteView:note animated:NO];
        }
        [self addNoteView:nil animated:NO];
    }
    return self;
}

- (void)createCountdownViewIfNeeded {
    if (self.index == -1) return;
    if ([self.period.date isEqualToDate:[IHWDate today]]) {
        int secondsUntil = [[IHWTime now] secondsUntilTime:self.period.startTime];
        if (secondsUntil > 0 &&
            ((self.index > 0 && [((IHWPeriod *)[self.dayViewController.day.periods objectAtIndex:self.index-1]).startTime secondsUntilTime:[IHWTime now]] > 0)
             || (self.index == 0 && secondsUntil < 60*60))) {
                self.countdownView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width-124, -10, 124+10, 24+10)];
                self.countdownView.backgroundColor = [UIColor colorWithRed:0.6 green:0 blue:0 alpha:1];
                self.countdownView.layer.cornerRadius = 10;
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectOffset(self.countdownView.bounds, 5, 4)];
                label.backgroundColor = [UIColor clearColor];
                label.text = [NSString stringWithFormat:@"Starts in %d:%02d", secondsUntil/60, secondsUntil%60];
                label.textColor = [UIColor whiteColor];
                label.font = [UIFont boldSystemFontOfSize:17];
                [self.countdownView addSubview:label];
                [self addSubview:self.countdownView];
                self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCountdownView) userInfo:nil repeats:YES];
            }
    }
}

- (void)updateCountdownView {
    int secondsUntil = [[IHWTime now] secondsUntilTime:self.period.startTime];
    if (secondsUntil >= 0) {
        UILabel *label = [self.countdownView.subviews objectAtIndex:0];
        label.text = [NSString stringWithFormat:@"Starts in %d:%02d", secondsUntil/60, secondsUntil%60];
    } else {
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;
        [self.countdownView removeFromSuperview];
        self.countdownView = nil;
        [self.dayViewController moveCountdownToPeriodAfterPeriodAtIndex:self.index];
    }
}

- (void)updateConstraints {
    [super updateConstraints];
    if (self.index == -1) {
        NSDictionary *views = @{@"title":self.titleLabel, @"notes":self.notesView};
        NSArray *constrants = [NSLayoutConstraint constraintsWithVisualFormat:@"|-4-[title(==notes)]-4-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:views];
        [self addConstraints:constrants];
        constrants = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[title][notes]-2-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:views];
        [self addConstraints:constrants];
    } else {
        NSDictionary *views = @{@"start":self.startLabel, @"period":self.periodLabel, @"end":self.endLabel, @"title":self.titleLabel, @"notes":self.notesView};
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[start(==title,==19)][period(>=24)][end(==19)]-2-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:views];
        [self addConstraints:constraints];
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-4-[start(==period,==end,==78)]-4-[title(==notes)]|" options:NSLayoutFormatAlignAllTop metrics:nil views:views];
        [self addConstraints:constraints];
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[title(==start,==19)][notes]-2-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:views];
        [self addConstraints:constraints];
    }
}

- (void)addNoteView:(IHWNote *)note animated:(BOOL)animated {
    int noteIndex = self.notesView.subviews.count;
    IHWNoteView *view = [[IHWNoteView alloc] initWithNote:note index:noteIndex cellView:self];
    [self.notesView addSubview:view];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self reLayoutViews:animated];
}

- (void)noteViewChangedAtIndex:(int)index {
    IHWNoteView *noteView = [self.notesView.subviews objectAtIndex:index];
    [self.period.notes setObject:noteView.note atIndexedSubscript:index];
    if (![noteView.textField.text isEqualToString:@""] && index == self.notesView.subviews.count-1) {
        [self addNoteView:nil animated:YES];
    } else if ([noteView.textField.text isEqualToString:@""] && index != self.notesView.subviews.count-1) {
        if (self.period.notes.count > index) [self.period.notes removeObjectAtIndex:index];
        [noteView removeFromSuperview];
        [self reLayoutViews:YES];
        IHWNoteView *nextFocus = [self.notesView.subviews objectAtIndex:index];
        [nextFocus.textField becomeFirstResponder];
        nextFocus.textField.selectedTextRange = [nextFocus.textField textRangeFromPosition:nextFocus.textField.beginningOfDocument toPosition:nextFocus.textField.beginningOfDocument];
    }
    [self saveNotes];
}

- (void)reLayoutViews:(BOOL)animated {
    [self.notesView removeConstraints:self.notesView.constraints];
    int yPos = 0;
    for (int index=0; index < self.notesView.subviews.count; index++) {
        IHWNoteView *view = [self.notesView.subviews objectAtIndex:index];
        view.index = index;
        [self.notesView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|" options:NSLayoutFormatAlignAllLeft metrics:nil views:@{@"view": view}]];
        [self.notesView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-yPos-[view]" options:NSLayoutFormatAlignAllLeft metrics:@{@"yPos": [NSNumber numberWithInt:yPos]} views:@{@"view": view}]];
        if (view.heightConstraint == nil) {
            view.heightConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:view.neededHeight];
            [self.notesView addConstraint:view.heightConstraint];
        }
        view.heightConstraint.constant = view.neededHeight;
        yPos += view.neededHeight;
    }
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, [self neededHeight]);
    if (animated) [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
    }];
    else [self layoutIfNeeded];
    if (self.dayViewController != nil) [self.dayViewController updateRowHeightAtIndex:self.index toHeight:[self neededHeight]];
}

- (void)saveNotes {
    //NSLog(@"Saving notes: %@", self.period.notes);
    [self.period saveNotes];
    self.dayViewController.hasUnsavedChanges = YES;
}

- (int)neededHeight {
    int noteHeight = 0;
    for (IHWNoteView *view in self.notesView.subviews) {
        noteHeight += view.neededHeight;
    }
    return MAX(72, noteHeight+3+19+2);
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

@end
