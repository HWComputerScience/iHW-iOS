//
//  IHWLabelCell.m
//  iHW
//
//  Created by Jonathan Burns on 8/15/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWLabelCell.h"

@implementation IHWLabelCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.textLabel];
    }
    return self;
}

- (void)didMoveToSuperview {
    //Hide this LabelCell if necessary when the cell is added to the collection view
    if (self.shouldHideOnAppear) self.hidden = YES;
}

@end
