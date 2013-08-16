//
//  IHWPeriodCellView.m
//  iHW
//
//  Created by Jonathan Burns on 8/14/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWPeriodCellView.h"
#import "IHWUtils.h"

@implementation IHWPeriodCellView

- (id)initWithPeriod:(IHWPeriod *)period forTableViewCell:(UITableViewCell *)cell;
{
    self = [super initWithFrame:cell.contentView.bounds];
    if (self) {
        self.period = period;
        
        self.startLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 3, 68, 19)];
        self.periodLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 22, 68, 30)];
        self.endLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 52, 68, 19)];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(76, 3, 100, 19)];
        
        self.startLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.periodLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.endLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.startLabel.font = [UIFont systemFontOfSize:15];
        self.periodLabel.font = [UIFont boldSystemFontOfSize:25];
        self.endLabel.font = [UIFont systemFontOfSize:15];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        
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
        
        NSDictionary *views = @{@"start":self.startLabel, @"period":self.periodLabel, @"end":self.endLabel, @"title":self.titleLabel};
        self.constraints = [[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[start(==title,==19)][period(>=24)][end(==19)]-3-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:views] arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-4-[start(==period,==end,==68)]-4-[title]-0-|" options:NSLayoutFormatAlignAllTop metrics:nil views:views]];
        [self addConstraints:self.constraints];
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

@end
