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

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    UIButton *button = ((IHWNoteView *)[self.notesView.subviews objectAtIndex:textField.tag]).optionsButton;
    button.hidden = NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    int noteIndex = textField.tag;
    IHWNoteView *view = [self.notesView.subviews objectAtIndex:noteIndex];
    
    if (![textField.text isEqualToString:@""]) {
        /*
        if (noteIndex < self.period.notes.count) {
            IHWNote *prevNote = [self.period.notes objectAtIndex:noteIndex];
            prevNote.text = textField.text;
        } else {
            IHWNote *prevNote = [[IHWNote alloc] initWithText:textField.text isToDo:NO isChecked:NO isImportant:NO];
            [self.period.notes setObject:prevNote atIndexedSubscript:noteIndex];
        }*/
        if (view.note == nil) {
            IHWNote *note = [view copyFieldsToNewNote];
            [self.period.notes setObject:note atIndexedSubscript:noteIndex];
        }
    }
    if (![textField.text isEqualToString:@""] && noteIndex == self.notesView.subviews.count-1) {
        [self addNoteView:nil animated:YES];
    } else if ([textField.text isEqualToString:@""] && noteIndex != self.notesView.subviews.count-1) {
        if (self.period.notes.count > noteIndex) [self.period.notes removeObjectAtIndex:noteIndex];
        [[self.notesView.subviews objectAtIndex:noteIndex] removeFromSuperview];
        [self reLayoutViews:YES];
        UITextField *nextFocus = ((IHWNoteView *)[self.notesView.subviews objectAtIndex:noteIndex]).textField;
        [nextFocus becomeFirstResponder];
        nextFocus.selectedTextRange = [nextFocus textRangeFromPosition:nextFocus.beginningOfDocument toPosition:nextFocus.beginningOfDocument];
    }
    [self saveNotes];
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    int noteIndex = textField.tag;
    UIButton *button = ((IHWNoteView *)[self.notesView.subviews objectAtIndex:noteIndex]).optionsButton;
    button.hidden = YES;
}

- (void)optionsButtonPressed:(UIButton *)button {
    int noteIndex = button.tag;
    NSString *todoTitle;
    if (((IHWNoteView *)[self.notesView.subviews objectAtIndex:noteIndex]).isToDo) todoTitle = @"Hide checkbox";
    else todoTitle = @"Show checkbox";
    NSString *importantTitle;
    if (((IHWNoteView *)[self.notesView.subviews objectAtIndex:noteIndex]).isImportant) importantTitle = @"Make unimportant";
    else importantTitle = @"Make important";
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Note Options" delegate:self cancelButtonTitle:@"Close" destructiveButtonTitle:nil otherButtonTitles:todoTitle, importantTitle, nil];
    sheet.tag = noteIndex;
    [sheet showFromToolbar:((IHWScheduleViewController *)[((IHWAppDelegate *)[UIApplication sharedApplication].delegate).navController.viewControllers objectAtIndex:0]).toolbar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    int noteIndex = actionSheet.tag;
    if (buttonIndex == 0) {
        [((IHWNoteView *)[self.notesView.subviews objectAtIndex:noteIndex]) toggleToDo];
    } else if (buttonIndex == 1) {
        [((IHWNoteView *)[self.notesView.subviews objectAtIndex:noteIndex]) toggleImportant];
    }
}

- (void)reLayoutViews:(BOOL)animated {
    [self.notesView removeConstraints:self.notesView.constraints];
    int yPos = 0;
    for (int index=0; index < self.notesView.subviews.count; index++) {
        IHWNoteView *view = [self.notesView.subviews objectAtIndex:index];
        for (UIView *subview in view.subviews) {
            subview.tag = index;
        }
        [self.notesView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|" options:NSLayoutFormatAlignAllLeft metrics:nil views:@{@"view": view}]];
        [self.notesView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-yPos-[view(==noteHeight)]" options:NSLayoutFormatAlignAllLeft metrics:@{@"yPos": [NSNumber numberWithInt:yPos], @"noteHeight":[NSNumber numberWithInt:NOTE_HEIGHT]} views:@{@"view": view}]];
        yPos += NOTE_HEIGHT;
    }
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, [self neededHeight]);
    if (animated) [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
    }];
    else [self layoutIfNeeded];
    if (self.dayViewController != nil) [self.dayViewController updateRowHeightAtIndex:self.index toHeight:[self neededHeight]];
}

- (void)saveNotes {
    NSLog(@"Saving notes: %@", self.period.notes);
    [self.period saveNotes];
    self.dayViewController.hasUnsavedChanges = YES;
}

- (int)neededHeight {
    return MAX(72, self.notesView.subviews.count*NOTE_HEIGHT+3+19+2);
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

@end
