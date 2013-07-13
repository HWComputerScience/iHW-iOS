//
//  IHWDate.m
//  iHW
//
//  Created by Andrew Friedman on 7/11/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import "IHWDate.h"

@implementation IHWDate

- (id)initWithMonth:(int)m day:(int)d year:(int)y
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = d;
    components.month = m;
    components.year = y;
    self = [super initWithTimeInterval:0 sinceDate:[[NSCalendar currentCalendar] dateFromComponents:components]];
    return self;
}

-(int)getMonth {
    return [[NSCalendar currentCalendar] components:NSMonthCalendarUnit fromDate:self].month;
}

-(int)getDay {
    return [[NSCalendar currentCalendar] components:NSMonthCalendarUnit fromDate:self].day;
}

-(int)getYear {
    return [[NSCalendar currentCalendar] components:NSMonthCalendarUnit fromDate:self].year;
}

@end
