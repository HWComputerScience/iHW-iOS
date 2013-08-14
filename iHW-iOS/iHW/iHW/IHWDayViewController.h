//
//  IHWDayViewController.h
//  iHW
//
//  Created by Jonathan Burns on 8/13/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IHWDate.h"
#import "IHWDay.h"

@interface IHWDayViewController : UIViewController

@property (nonatomic, strong) IHWDate *date;
@property (nonatomic, strong) IHWDay *day;
@property (weak, nonatomic) IBOutlet UILabel *weekdayLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *periodScrollView;

- (id)initWithDate:(IHWDate *)date;

@end
