//
//  IHWCheckboxCell.m
//  iHW
//
//  Created by Jonathan Burns on 8/15/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWCheckboxCell.h"

@implementation IHWCheckboxCell

@synthesize checked = _checked;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.checkboxButton = [[UIButton alloc] initWithFrame:self.contentView.bounds];
        [self.checkboxButton addTarget:self action:@selector(toggleChecked) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.checkboxButton];
        self.checked = NO;
    }
    return self;
}

- (void)didMoveToSuperview {
    if (self.shouldHideOnAppear) self.hidden = YES;
}

- (void)toggleChecked {
    self.checked = !self.checked;
}

- (void)setChecked:(BOOL)checked {
    BOOL changed = (_checked != checked);
    _checked = checked;
    if (checked) {
        [self.checkboxButton setImage:[UIImage imageNamed:@"checkboxChecked"] forState:UIControlStateNormal];
        [self.checkboxButton setImage:[UIImage imageNamed:@"checkboxChecked"] forState:UIControlStateHighlighted];
    } else {
        [self.checkboxButton setImage:[UIImage imageNamed:@"checkboxUnchecked"] forState:UIControlStateNormal];
        [self.checkboxButton setImage:[UIImage imageNamed:@"checkboxUnchecked"] forState:UIControlStateHighlighted];
    }
    if (changed && [self.delegate respondsToSelector:@selector(checkboxCell:didChangeCheckedStateToState:)]) [self.delegate checkboxCell:self didChangeCheckedStateToState:checked];
}

@end
