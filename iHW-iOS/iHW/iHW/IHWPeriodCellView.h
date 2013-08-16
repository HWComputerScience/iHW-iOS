//
//  IHWPeriodCellView.h
//  iHW
//
//  Created by Jonathan Burns on 8/14/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IHWPeriod.h"

@interface IHWPeriodCellView : UIView

@property (nonatomic, weak) IHWPeriod *period;

@property (nonatomic, strong) UILabel *startLabel;
@property (nonatomic, strong) UILabel *endLabel;
@property (nonatomic, strong) UILabel *periodLabel;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) NSArray *constraints;

- (id)initWithPeriod:(IHWPeriod *)period forTableViewCell:(UITableViewCell *)cell;

@end
