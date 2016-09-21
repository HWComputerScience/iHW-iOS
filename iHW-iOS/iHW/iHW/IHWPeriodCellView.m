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
#import "IHWFileManager.h"
#import "IHWCurriculum.h"
#import "CJSONDeserializer.h"
#import "IHWCalendarEvent.h"
#import <QuartzCore/QuartzCore.h>

@implementation IHWPeriodCellView

//A regular period cell view for a period of the day
- (id)initWithPeriod:(IHWPeriod *)period atIndex:(int)index forTableViewCell:(UITableViewCell *)cell;
{
    self = [super initWithFrame:CGRectMake(0, 0, cell.bounds.size.width, 1000)];
    if (self) {
        
        self.period = period;
        self.index = index;
        int leftColumnWidth = 76;
        int rightColumnWidth = self.frame.size.width-leftColumnWidth-8;
        
        //Create labels
        self.startLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 3, leftColumnWidth, 19)];
        self.periodLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 22, leftColumnWidth, 30)];
        self.endLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 52, leftColumnWidth, 19)];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftColumnWidth+8, 3, rightColumnWidth, 19)];
        self.notesView = [[UIView alloc] initWithFrame:CGRectMake(leftColumnWidth+8, 22, rightColumnWidth, 49)];
        
        //Setup fonts
        self.startLabel.font = [UIFont systemFontOfSize:17];
        self.periodLabel.font = [UIFont boldSystemFontOfSize:25];
        self.endLabel.font = [UIFont systemFontOfSize:17];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        
        //Add text to labels
        self.startLabel.text = self.period.startTime.description12;
        if (self.period.periodNum != 0)
            self.periodLabel.text = getOrdinal(self.period.periodNum);
        else self.periodLabel.hidden = YES;
        self.endLabel.text = self.period.endTime.description12;
        self.titleLabel.text = self.period.name;
        
        //Add labels to view
        [self addSubview:self.startLabel];
        [self addSubview:self.periodLabel];
        [self addSubview:self.endLabel];
        [self addSubview:self.titleLabel];
        [self addSubview:self.notesView];
        
        //Setup constraints
        self.clipsToBounds = YES;
        self.startLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.periodLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.endLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *views = @{@"start":self.startLabel, @"period":self.periodLabel, @"end":self.endLabel};
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[start(==19)][period(>=24)][end(==19)]-2-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-4-[start(==period,==end,==76)]" options:NSLayoutFormatAlignAllLeft metrics:nil views:views]];
        
        //Add Calendar Events from Hub to noteView
        NSData *calendarJSON = [IHWFileManager loadCalendarJSONForYear:[IHWCurriculum currentYear] campus:getCampusChar([IHWCurriculum currentCampus])];
        NSError *error;
        NSDictionary *calendarJSONDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:calendarJSON error:&error];
        
        if (error != nil) {
            NSLog(@"Error parsing JSON.");
        } else {
            NSArray *coursesJSON = [calendarJSONDict objectForKey:@"events"];
            for (NSDictionary *event in coursesJSON) {
                NSLog(@"%@", self.period.courseID);
                if([self.period.date.getCanvasDateString isEqualToString:event[@"date"]] && [[NSString stringWithFormat:@"%@",self.period.courseID] isEqualToString:[NSString stringWithFormat:@"%@",event[@"courseID"]]]) {
                    IHWNote *note = [[IHWNote alloc] initWithText:event[@"title"] isToDo:NO isChecked:NO isImportant:YES];
                    [self addNoteView:note animated:NO willAddMore:YES];
                }
            }
        }
        //Add notes to noteView
        for (IHWNote *note in self.period.notes) {
            [self addNoteView:note animated:NO willAddMore:YES];
        }
        [self addNoteView:nil animated:NO willAddMore:NO];
    }
    return self;
}

//The "additional notes" cell view that is shown below the other periods
- (id)initWithAdditionalNotesOnDate:(IHWDate *)date withFrame:(CGRect)frame onHoliday:(BOOL)holiday {
    self = [super initWithFrame:frame];
    if (self) {
        self.index = -1; //Index -1 means "additional notes"
        self.period = [[IHWPeriod alloc] initWithName:@"Additional Notes" date:date start:[[IHWTime alloc] initWithHour:0 andMinute:0] end:[[IHWTime alloc] initWithHour:0 andMinute:0] number:0 index:self.index isFreePeriod:NO];
        
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

- (BOOL)createCountdownViewIfNeeded {
    if (self.index == -1) return NO;
    //Only create countdown view if this period is today...
    if ([self.period.date isEqualToDate:[IHWDate today]]) {
        int secondsUntil = [[IHWTime now] secondsUntilTime:self.period.startTime];
        //...and the time is between last period's startTime and this period's startTime...
        //...or this is the first period and it starts in less than an hour.
        if (secondsUntil > 0 &&
            ((self.index > 0 && [((IHWPeriod *)[self.dayViewController.day.periods objectAtIndex:self.index-1]).startTime secondsUntilTime:[IHWTime now]] > 0)
             || (self.index == 0 && secondsUntil < 60*60))) {
                //Configure countdown view
                self.countdownView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width-124, -10, 124+10, 24+10)];
                self.countdownView.backgroundColor = [UIColor colorWithRed:0.6 green:0 blue:0 alpha:1];
                self.countdownView.layer.cornerRadius = 10;
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectOffset(self.countdownView.bounds, 5, 4)];
                label.backgroundColor = [UIColor clearColor];
                label.text = [NSString stringWithFormat:@"Starts in %d:%02d", secondsUntil/60, secondsUntil%60];
                label.textColor = [UIColor whiteColor];
                label.font = [UIFont boldSystemFontOfSize:17];
                [self.countdownView addSubview:label];
                //add the countdown view to the period view
                [self addSubview:self.countdownView];
                //Set a timer to update the countdown
                self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCountdownView) userInfo:nil repeats:YES];
                [self updateCountdownView];
                return YES;
            }
    }
    return NO;
}

- (void)updateCountdownView {
    int secondsUntil = [[IHWTime now] secondsUntilTime:self.period.startTime];
    UILabel *label = [self.countdownView.subviews objectAtIndex:0];
    if (secondsUntil >= 60*60) {
        label.text = [NSString stringWithFormat:@"Starts in %d:%02d:%02d", secondsUntil/3600,(secondsUntil%3600)/60, secondsUntil%60];
    } else if (secondsUntil >= 0) {
        label.text = [NSString stringWithFormat:@"Starts in %d:%02d", secondsUntil/60, secondsUntil%60];
    } else {
        //The period is starting now -- remove the countdown view
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;
        [self.countdownView removeFromSuperview];
        self.countdownView = nil;
        [self.dayViewController moveCountdownToPeriodAfterPeriodAtIndex:self.index];
    }
}

- (void)addNoteView:(IHWNote *)note animated:(BOOL)animated willAddMore:(BOOL)willAddMore {
    //Add a new IHWNoteView to the end of the notesView.
    int noteIndex = (int)self.notesView.subviews.count;
    IHWNoteView *view = [[IHWNoteView alloc] initWithNote:note index:noteIndex cellView:self];
    [self.notesView addSubview:view];
    if (!willAddMore) [self reLayoutViews:animated];
}

- (void)noteViewChangedAtIndex:(int)index {
    IHWNoteView *noteView = [self.notesView.subviews objectAtIndex:index];
    //Create an IHWNote object from the noteView
    if (noteView.note == nil) [noteView copyFieldsToNewNote];
    IHWNote *note = noteView.note;
    [self.period.notes setObject:note atIndexedSubscript:index];
    if (![noteView.textField.text isEqualToString:@""] && index == self.notesView.subviews.count-1) {
        //Add another empty note view below this one if it's the last view and not empty
        [self addNoteView:nil animated:YES willAddMore:NO];
    } else if ([noteView.textField.text isEqualToString:@""] && index != self.notesView.subviews.count-1) {
        //Delete empty note view if it's not the last view
        if (self.period.notes.count > index) [self.period.notes removeObjectAtIndex:index];
        [noteView removeFromSuperview];
        [self reLayoutViews:YES];
        //Move cursor to the beginning of the next view
        IHWNoteView *nextFocus = [self.notesView.subviews objectAtIndex:index];
        [nextFocus.textField becomeFirstResponder];
        nextFocus.textField.selectedTextRange = [nextFocus.textField textRangeFromPosition:nextFocus.textField.beginningOfDocument toPosition:nextFocus.textField.beginningOfDocument];
    }
    //Save it
    [self saveNotes];
}

- (void)reLayoutViews:(BOOL)animated {
    int yPos = 0;
    for (int index=0; index < self.notesView.subviews.count; index++) {
        //For each note view, set its index and position its frame in the right place
        IHWNoteView *view = [self.notesView.subviews objectAtIndex:index];
        view.index = index;
        view.frame = CGRectMake(0, yPos, self.notesView.bounds.size.width, view.neededHeight);
        yPos += view.neededHeight;
    }
    int neededHeight = [self neededHeight];
    //Set this view's frame
    self.frame = CGRectMake(0, 0, self.frame.size.width, neededHeight);
    //Change the notes view's height to fill the rest of this period's height
    self.notesView.frame = CGRectMake(self.notesView.frame.origin.x, self.notesView.frame.origin.y, self.notesView.frame.size.width, neededHeight-self.notesView.frame.origin.y);
    [self setNeedsLayout];
    //Animate if necessary
    if (animated) [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
    }];
    else {
        [self.dayViewController.periodsTableView layoutIfNeeded];
    }
    if (self.dayViewController != nil) {
        //Tell the day view to update the height allocated for this period
        [self.dayViewController updateRowHeightAtIndex:self.index toHeight:neededHeight];
    }
}

- (void)saveNotes {
    //NSLog(@"Saving notes: %@", self.period.notes);
    [self.period saveNotes];
    self.dayViewController.hasUnsavedChanges = YES;
}

- (int)neededHeight {
    //Calculate the height needed to display this period
    int noteHeight = 0;
    for (IHWNoteView *view in self.notesView.subviews) {
        noteHeight += view.neededHeight;
    }
    return MAX(72, noteHeight+3+19+2);
}

@end
