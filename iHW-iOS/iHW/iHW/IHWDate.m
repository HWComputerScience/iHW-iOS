//
//  IHWDate.m
//  iHW
//
//  Created by Jonathan Burns on 7/11/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWDate.h"

@implementation NSDate (IHW)

+ (IHWDate *)IHWDate {
    return [[IHWDate alloc] initIHWDate];
}

- (id)initIHWDate
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[self init]];
    self = [[NSCalendar currentCalendar] dateFromComponents:components];
    return self;
}

- (id)initWithMonth:(int)m day:(int)d year:(int)y
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = d;
    components.month = m;
    components.year = y;
    self = [[NSCalendar currentCalendar] dateFromComponents:components];
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

- (NSDate *)dateByAddingDays:(int)days {
    return [[NSDate alloc] initWithTimeInterval:days*24*60*60 sinceDate:self];
}

- (NSDate *)dateOfNextSunday {
    int weekday = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:self].weekday;
    int daysBehind = 8-weekday;
    return [self dateByAddingDays:daysBehind];
}

- (NSDate *)dateOfPreviousSunday {
    int weekday = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:self].weekday;
    int daysAhead = weekday-1;
    return [self dateByAddingDays:-daysAhead];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%d/%d/%d", self.month, self.day, self.year];
}

- (int)daysUntilDate:(NSDate *)other {
    return [other timeIntervalSinceDate:self]/60/60/24;
}

- (NSString *)dayOfWeek:(BOOL)shortVersion {
    NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
    if (shortVersion) [weekday setDateFormat: @"EEE"];
    else [weekday setDateFormat:@"EEEE"];
    return [weekday stringFromDate:self];
}

- (BOOL)isEqualToDate:(NSDate *)other {
    if (![other isKindOfClass:[NSDate class]]) return NO;
    NSDate *otherDate = (NSDate *)other;
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
    return ^(NSDate *obj1, NSDate *obj2) {
        return [obj1 compare:obj2];
    };
}

@end
