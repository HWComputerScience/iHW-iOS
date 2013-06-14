//
//  IHWNormalDay.m
//  iHW
//
//  Created by Andrew Friedman on 6/14/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import "IHWNormalDay.h"

@class IHWSchedule;

@implementation IHWNormalDay

- (id)initWithDayNumber:(int)day
             numPeriods:(int)periods
           periodLength:(int)length
{
    self = [super init];
    if (self) {
        self.dayNumber = day;
        self.numPeriods = periods;
        self.periodLength = length;
    }
    return self;
}
- (id)initWithBreakName:(NSString *)name
            breakLength:(int)length
              dayNumber:(int)day
             numPeriods:(int)periods
           periodLength:(int)pLength
     periodsBeforeBreak:(int)pBefore
{
    self = [self initWithDayNumber:day
                        numPeriods:periods
                      periodLength:pLength];
    if (self) {
        self.breakName = name;
        self.breakLength = length;
        self.periodsBeforeBreak = pBefore;
        self.periodsAfterBreak = self.numPeriods - pBefore;
        self.hasBreak = TRUE;
    }
    return self;
}

-(void)fillPeriodsFromSchedule:(IHWSchedule *)sched {
    
}

@end
