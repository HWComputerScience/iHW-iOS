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
        //self.backgroundColor = [UIColor redColor];
        
        self.period = period;
        self.index = index;
        int leftColumnWidth = 76;
        int rightColumnWidth = self.frame.size.width-leftColumnWidth-8;
        
        self.startLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 3, leftColumnWidth, 19)];
        self.periodLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 22, leftColumnWidth, 30)];
        self.endLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 52, leftColumnWidth, 19)];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftColumnWidth+8, 3, rightColumnWidth, 19)];
        self.notesView = [[UIView alloc] initWithFrame:CGRectMake(leftColumnWidth+8, 22, rightColumnWidth, 49)];
        
        self.clipsToBounds = YES;
        self.startLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.periodLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.endLabel.translatesAutoresizingMaskIntoConstraints = NO;
                
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
        
        NSDictionary *views = @{@"start":self.startLabel, @"period":self.periodLabel, @"end":self.endLabel};
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[start(==19)][period(>=24)][end(==19)]-2-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:views]];
        
        for (IHWNote *note in self.period.notes) {
            [self addNoteView:note animated:NO willAddMore:YES];
        }
        [self addNoteView:nil animated:NO willAddMore:NO];
    }
    return self;
}

- (id)initWithAdditionalNotesOnDate:(IHWDate *)date withFrame:(CGRect)frame onHoliday:(BOOL)holiday {
    self = [super initWithFrame:frame];
    if (self) {
        self.index = -1;
        self.period = [[IHWPeriod alloc] initWithName:@"Additional Notes" date:date start:[[IHWTime alloc] initWithHour:0 andMinute:0] end:[[IHWTime alloc] initWithHour:0 andMinute:0] number:0 index:self.index];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 3, self.bounds.size.width-8, 19)];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        if (holiday) self.titleLabel.text = @"Notes";
        else self.titleLabel.text = @"Additional Notes";
        [self addSubview:self.titleLabel];
        
        self.notesView = [[UIView alloc] initWithFrame:CGRectMake(4, 22, self.bounds.size.width-8, 49)];
        [self addSubview:self.notesView];
        
        for (IHWNote *note in self.period.notes) {
            [self addNoteView:note animated:NO willAddMore:YES];
        }
        [self addNoteView:nil animated:NO willAddMore:NO];
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

- (void)addNoteView:(IHWNote *)note animated:(BOOL)animated willAddMore:(BOOL)willAddMore {
    int noteIndex = self.notesView.subviews.count;
    IHWNoteView *view = [[IHWNoteView alloc] initWithNote:note index:noteIndex cellView:self];
    [self.notesView addSubview:view];
    if (!willAddMore) [self reLayoutViews:animated];
}

- (void)noteViewChangedAtIndex:(int)index {
    IHWNoteView *noteView = [self.notesView.subviews objectAtIndex:index];
    if (noteView.note == nil) [noteView copyFieldsToNewNote];
    IHWNote *note = noteView.note;
    [self.period.notes setObject:note atIndexedSubscript:index];
    if (![noteView.textField.text isEqualToString:@""] && index == self.notesView.subviews.count-1) {
        [self addNoteView:nil animated:YES willAddMore:NO];
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
    int yPos = 0;
    for (int index=0; index < self.notesView.subviews.count; index++) {
        IHWNoteView *view = [self.notesView.subviews objectAtIndex:index];
        view.index = index;
        view.frame = CGRectMake(0, yPos, self.notesView.bounds.size.width, view.neededHeight);
        yPos += view.neededHeight;
    }
    int neededHeight = self.neededHeight;
    self.frame = CGRectMake(0, 0, self.frame.size.width, neededHeight);
    [self setNeedsLayout];
    if (animated) [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
    }];
    else [self layoutIfNeeded];
    if (self.dayViewController != nil) [self.dayViewController updateRowHeightAtIndex:self.index toHeight:neededHeight];
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

@end
