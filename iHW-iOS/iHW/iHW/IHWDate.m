//
//  IHWDate.m
//  iHW
//
//  Created by Jonathan Burns on 7/11/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWDate.h"

@implementation NSDate (IHW)

- (id)init
{
    self = [super init];
    return self;
}

- (id)initWithMonth:(int)m day:(int)d year:(int)y
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = d;
    components.month = m;
    components.year = y;
    self = [self initWithTimeInterval:0 sinceDate:[[NSCalendar currentCalendar] dateFromComponents:components]];
    return self;
}

- (id)initFromString:(NSString *)string
{
    NSArray *comps = [string componentsSeparatedByString:@"/"];
    self = [self initWithMonth:[[comps objectAtIndex:0] intValue] day:[[comps objectAtIndex:1] intValue] year:[[comps objectAtIndex:2] intValue]];
    return self;
}

-(int)month {
    return [[NSCalendar currentCalendar] components:NSMonthCalendarUnit fromDate:self].month;
}

-(int)day {
    return [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:self].day;
}

-(int)year {
    return [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:self].year;
}

- (BOOL)isMonday {
    int weekday = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:self].weekday;
    return weekday==2;
}

- (BOOL)isWeekend {
    int weekday = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:self].weekday;
    return weekday==1 || weekday == 7;
}

- (IHWDate *)dateByAddingDays:(int)days {
    return [[IHWDate alloc] initWithTimeInterval:days*24*60*60 sinceDate:self];
}

- (IHWDate *)dateOfNextSunday {
    int weekday = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:self].weekday;
    int daysBehind = 8-weekday;
    return [self dateByAddingDays:daysBehind];
}

- (IHWDate *)dateOfPreviousSunday {
    int weekday = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:self].weekday;
    int daysAhead = weekday-1;
    return [self dateByAddingDays:-daysAhead];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%d/%d/%d", self.month, self.day, self.year];
}

- (int)daysUntilDate:(IHWDate *)other {
    return [other timeIntervalSinceDate:self]/60/60/24;
}

- (NSString *)dayOfWeek:(BOOL)shortVersion {
    NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
    if (shortVersion) [weekday setDateFormat: @"EEE"];
    else [weekday setDateFormat:@"EEEE"];
    return [weekday stringFromDate:self];
}

- (BOOL)isEqualToDate:(NSDate *)other {
    if (![other isKindOfClass:[IHWDate class]]) return NO;
    IHWDate *otherDate = (IHWDate *)other;
    return (self.month == otherDate.month && self.day == otherDate.day && self.year == otherDate.year);
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[IHWDate class]]) return NO;
    return [self isEqualToDate:object];
}

- (NSUInteger)hash {
    return self.description.hash;
}

+ (NSComparator)comparator {
    return ^(IHWDate *obj1, IHWDate *obj2) {
        return [obj1 compare:obj2];
    };
}

@end
