//
//  IHWNoteView.h
//  iHW
//
//  Created by Jonathan Burns on 8/21/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IHWNote.h"
#import "IHWPeriodCellView.h"

@interface IHWNoteView : UIView <UITextFieldDelegate, UIActionSheetDelegate>

@property int index;
@property (nonatomic, strong) UIButton *checkbox;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *optionsButton;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, strong) NSArray *constraints;
@property (nonatomic, strong) IHWNote *note;
@property (nonatomic, weak) IHWPeriodCellView *delegate;

- (id)initWithNote:(IHWNote *)note index:(int)noteIndex cellView:(IHWPeriodCellView *)cellView;

- (void)copyFieldsToNewNote;
- (void)setToDo:(BOOL)isToDo;
- (BOOL)isToDo;
- (void)toggleToDo;
- (BOOL)isChecked;
- (void)setChecked:(BOOL)checked;
- (void)toggleChecked;
- (BOOL)isImportant;
- (void)setImportant:(BOOL)important;
- (void)toggleImportant;
- (int)neededHeight;

@end
