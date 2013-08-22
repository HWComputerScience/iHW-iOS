//
//  IHWNoteView.m
//  iHW
//
//  Created by Jonathan Burns on 8/21/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWNoteView.h"
#import "IHWScheduleViewController.h"
#import "IHWAppDelegate.h"

#define NOTE_HEIGHT 24
#define BUTTON_WIDTH 24
#define IMPORTANT_NOTE_HEIGHT 30

@implementation IHWNoteView
@synthesize note = _note;

- (id)initWithNote:(IHWNote *)note index:(int)noteIndex cellView:(IHWPeriodCellView *)cellView
{
    CGRect frame = CGRectZero;
    if (cellView.notesView.subviews.count > 0){
        IHWNoteView *previous = [cellView.notesView.subviews objectAtIndex:cellView.notesView.subviews.count-1];
        CGFloat yPos = previous.frame.origin.y+previous.neededHeight;
        frame = CGRectMake(4, yPos, cellView.notesView.bounds.size.width, 0);
    }
    self = [super initWithFrame:frame];
    if (self) {
        self.index = noteIndex;
        self.delegate = cellView;
        
        self.checkbox = [[UIButton alloc] initWithFrame:CGRectZero];
        self.checkbox.translatesAutoresizingMaskIntoConstraints = NO;
        [self.checkbox setImage:[UIImage imageNamed:@"checkboxUnchecked"] forState:UIControlStateNormal];
        [self.checkbox setImage:[UIImage imageNamed:@"checkboxUnchecked"] forState:UIControlStateSelected|UIControlStateHighlighted];
        [self.checkbox setImage:[UIImage imageNamed:@"checkboxChecked"] forState:UIControlStateSelected];
        [self.checkbox setImage:[UIImage imageNamed:@"checkboxChecked"] forState:UIControlStateHighlighted];
        [self addSubview:self.checkbox];
        [self.checkbox addTarget:self action:@selector(toggleChecked) forControlEvents:UIControlEventTouchUpInside];
        
        self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
        self.textField.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.textField];
        self.textField.adjustsFontSizeToFitWidth = YES;
        self.textField.minimumFontSize = 12;
        self.textField.placeholder = @"Add a note";
        self.textField.borderStyle = UITextBorderStyleNone;
        self.textField.delegate = self;
        self.textField.returnKeyType = UIReturnKeyDone;
        
        self.optionsButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.optionsButton setImage:[UIImage imageNamed:@"graygear"] forState:UIControlStateNormal];
        [self addSubview:self.optionsButton];
        self.optionsButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.optionsButton.hidden = YES;
        [self.optionsButton addTarget:self action:@selector(optionsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        self.note = note;
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    if (self.constraints != nil) [self removeConstraints:self.constraints];
    int checkboxWidth = BUTTON_WIDTH;
    int checkboxMargin = 4;
    if (self.checkbox.hidden) { checkboxWidth = 0; checkboxMargin = 0; }
    NSDictionary *metrics = @{@"noteHeight":[NSNumber numberWithInt:[self neededHeight]], @"checkboxWidth":[NSNumber numberWithInt:checkboxWidth], @"checkboxMargin":[NSNumber numberWithInt:checkboxMargin]};
    NSDictionary *views = @{@"checkbox":self.checkbox, @"text": self.textField, @"button":self.optionsButton};
    self.constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-4-[checkbox(==checkboxWidth)]-checkboxMargin-[text][button(==noteHeight)]-4-|" options:NSLayoutFormatAlignAllTop metrics:metrics views:views];
    self.constraints = [self.constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[text(==checkbox,==button,==noteHeight)]|" options:NSLayoutFormatAlignAllTop metrics:metrics views:views]];
    [self addConstraints:self.constraints];
}

- (void)setNote:(IHWNote *)note {
    _note = note;
    if (note != nil) {
        [self setToDo:note.isToDo];
        [self setChecked:note.isChecked];
        [self setImportant:note.isImportant];
        self.textField.text = note.text;
    } else {
        [self setToDo:NO];
        [self setChecked:NO];
        [self setImportant:NO];
    }
}

- (void)copyFieldsToNewNote {
    _note = [[IHWNote alloc] initWithText:self.textField.text isToDo:self.isToDo isChecked:self.isChecked isImportant:self.isImportant];
}

- (void)setToDo:(BOOL)isToDo {
    self.checkbox.hidden = !isToDo;
    if (self.note != nil) self.note.isToDo = isToDo;
    [self setNeedsUpdateConstraints];
}

- (BOOL)isToDo {
    return !self.checkbox.hidden;
}

- (void)toggleToDo {
    [self setToDo:![self isToDo]];
    [self.delegate noteViewChangedAtIndex:self.index];
}

- (BOOL)isChecked {
    return self.checkbox.selected;
}

- (void)setChecked:(BOOL)checked {
    self.checkbox.selected = checked;
    if (self.note != nil) self.note.isChecked = checked;
}

- (void)toggleChecked {
    [self setChecked:![self isChecked]];
    [self.delegate noteViewChangedAtIndex:self.index];
}

- (BOOL)isImportant {
    return self.note.isImportant;
}

- (void)setImportant:(BOOL)important {
    if (important) {
        self.textField.font = [UIFont boldSystemFontOfSize:23];
        self.textField.textColor = [UIColor colorWithRed:0.6 green:0 blue:0 alpha:1];
    } else {
        self.textField.font = [UIFont systemFontOfSize:17];
        self.textField.textColor = [UIColor blackColor];
    }
    if (self.note != nil) self.note.isImportant = important;
    [self.delegate reLayoutViews:YES];
    [self setNeedsUpdateConstraints];
}

- (void)toggleImportant {
    [self setImportant:![self isImportant]];
    [self.delegate noteViewChangedAtIndex:self.index];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.optionsButton.hidden = NO;
    if (self.delegate.index == -1) self.delegate.dayViewController.scrollToIndex = self.delegate.dayViewController.cells.count-1;
    else self.delegate.dayViewController.scrollToIndex = self.delegate.index;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (self.note == nil) [self copyFieldsToNewNote];
    else self.note.text = textField.text;
    [self.delegate noteViewChangedAtIndex:self.index];
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.optionsButton.hidden = YES;
}

- (void)optionsButtonPressed:(UIButton *)button {
    NSString *todoTitle;
    if (self.isToDo) todoTitle = @"Hide checkbox";
    else todoTitle = @"Show checkbox";
    NSString *importantTitle;
    if (self.isImportant) importantTitle = @"Make unimportant";
    else importantTitle = @"Make important";
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Note Options" delegate:self cancelButtonTitle:@"Close" destructiveButtonTitle:nil otherButtonTitles:todoTitle, importantTitle, nil];
    [sheet showFromToolbar:((IHWScheduleViewController *)[((IHWAppDelegate *)[UIApplication sharedApplication].delegate).navController.viewControllers objectAtIndex:0]).toolbar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self toggleToDo];
    } else if (buttonIndex == 1) {
        [self toggleImportant];
    }
}

- (int)neededHeight {
    if (self.isImportant) return IMPORTANT_NOTE_HEIGHT;
    else return NOTE_HEIGHT;
}

@end
