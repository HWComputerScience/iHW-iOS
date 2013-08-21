//
//  IHWNoteView.m
//  iHW
//
//  Created by Jonathan Burns on 8/21/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWNoteView.h"

@implementation IHWNoteView
@synthesize note = _note;

- (id)initWithNote:(IHWNote *)note index:(int)noteIndex cellView:(IHWPeriodCellView *)cellView
{
    int yPos = noteIndex*NOTE_HEIGHT;
    self = [super initWithFrame:CGRectMake(4, yPos, cellView.notesView.bounds.size.width, NOTE_HEIGHT)];
    if (self) {
        
        self.checkbox = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, NOTE_HEIGHT)];
        self.checkbox.translatesAutoresizingMaskIntoConstraints = NO;
        [self.checkbox setImage:[UIImage imageNamed:@"checkboxUnchecked"] forState:UIControlStateNormal];
        [self.checkbox setImage:[UIImage imageNamed:@"checkboxUnchecked"] forState:UIControlStateSelected|UIControlStateHighlighted];
        [self.checkbox setImage:[UIImage imageNamed:@"checkboxChecked"] forState:UIControlStateSelected];
        [self.checkbox setImage:[UIImage imageNamed:@"checkboxChecked"] forState:UIControlStateHighlighted];
        [self addSubview:self.checkbox];
        //[self.checkbox addTarget:self action:@selector(toggleChecked) forControlEvents:UIControlEventTouchUpInside];
        
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width-NOTE_HEIGHT, NOTE_HEIGHT)];
        self.textField.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.textField];
        self.textField.placeholder = @"Add a note";
        self.textField.borderStyle = UITextBorderStyleNone;
        self.textField.delegate = cellView;
        self.textField.returnKeyType = UIReturnKeyDone;
        self.textField.tag = noteIndex;
        
        self.optionsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.bounds.size.width-NOTE_HEIGHT, NOTE_HEIGHT, NOTE_HEIGHT)];
        [self.optionsButton setImage:[UIImage imageNamed:@"graygear"] forState:UIControlStateNormal];
        [self addSubview:self.optionsButton];
        self.optionsButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.optionsButton.hidden = YES;
        self.optionsButton.tag = noteIndex;
        [self.optionsButton addTarget:cellView action:@selector(optionsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        self.note = note;
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    if (self.constraints != nil) [self removeConstraints:self.constraints];
    int checkboxWidth = NOTE_HEIGHT;
    int checkboxMargin = 4;
    if (self.checkbox.hidden) { checkboxWidth = 0; checkboxMargin = 0; }
    NSDictionary *metrics = @{@"noteHeight":[NSNumber numberWithInt:NOTE_HEIGHT], @"checkboxWidth":[NSNumber numberWithInt:checkboxWidth], @"checkboxMargin":[NSNumber numberWithInt:checkboxMargin]};
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

- (IHWNote *)copyFieldsToNewNote {
    return [[IHWNote alloc] initWithText:self.textField.text isToDo:self.isToDo isChecked:self.isChecked isImportant:self.isImportant];
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
}

- (BOOL)isChecked {
    return self.checkbox.selected;
}

- (void)setChecked:(BOOL)checked {
    //BOOL changed = (self.checkbox.selected != checked);
    self.checkbox.selected = checked;
    if (self.note != nil) self.note.isChecked = checked;
    //if (changed && [self.delegate respondsToSelector:@selector(checkboxCell:didChangeCheckedStateToState:)]) [self.delegate checkboxCell:self didChangeCheckedStateToState:checked];
}

- (void)toggleChecked {
    [self setChecked:![self isChecked]];
}

- (BOOL)isImportant {
    return self.note.isImportant;
}

- (void)setImportant:(BOOL)important {
    if (self.note != nil) self.note.isImportant = important;
}

- (void)toggleImportant {
    [self setImportant:![self isImportant]];
}

@end
