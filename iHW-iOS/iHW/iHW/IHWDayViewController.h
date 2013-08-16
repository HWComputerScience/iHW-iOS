//
//  IHWDayViewController.h
//  iHW
//
//  Created by Jonathan Burns on 8/13/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IHWDate.h"
#import "IHWDay.h"

@interface IHWDayViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IHWDate *date;
@property (nonatomic, strong) IHWDay *day;
@property (nonatomic, strong) NSMutableArray *rowHeights;

@property (weak, nonatomic) IBOutlet UILabel *weekdayLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *periodsTableView;
@property (weak, nonatomic) IBOutlet UILabel *dayNameLabel;

- (id)initWithDate:(IHWDate *)date;

@end
