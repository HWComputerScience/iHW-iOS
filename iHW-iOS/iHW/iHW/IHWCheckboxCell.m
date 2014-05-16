//
//  IHWCheckboxCell.m
//  iHW
//
//  Created by Jonathan Burns on 8/15/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWCheckboxCell.h"

@implementation IHWCheckboxCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //Checkboxes are really just UIButtons with images
        self.checkboxButton = [[UIButton alloc] initWithFrame:self.contentView.bounds];
        [self.checkboxButton addTarget:self action:@selector(toggleChecked) forControlEvents:UIControlEventTouchUpInside];
        NSString *suffix = @"";
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) suffix = @"_old";
        //Setup images
        [self.checkboxButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"checkboxUnchecked%@", suffix]] forState:UIControlStateNormal];
        [self.checkboxButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"checkboxUnchecked%@", suffix]] forState:UIControlStateSelected|UIControlStateHighlighted];
        [self.checkboxButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"checkboxChecked%@", suffix]] forState:UIControlStateSelected];
        [self.checkboxButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"checkboxChecked%@", suffix]] forState:UIControlStateHighlighted];
        [self.contentView addSubview:self.checkboxButton];
        //self.checked = NO;
    }
    return self;
}

- (void)didMoveToSuperview {
    //Hide this CheckboxCell if necessary when the cell is added to the collection view
    if (self.shouldHideOnAppear) self.hidden = YES;
}

- (void)toggleChecked {
    self.checked = !self.checked;
}

- (BOOL)checked {
    return self.checkboxButton.selected;
}

- (void)setChecked:(BOOL)checked {
    BOOL changed = (self.checkboxButton.selected != checked);
    self.checkboxButton.selected = checked;
    //Notify the delegate if this cell has changed state
    if (changed && [self.delegate respondsToSelector:@selector(checkboxCell:didChangeCheckedStateToState:)]) [self.delegate checkboxCell:self didChangeCheckedStateToState:checked];
}

@end
