//
//  IHWDate.m
//  iHW
//
//  Created by Jonathan Burns on 7/11/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWDate.h"

static NSCalendar *cal;

@implementation NSDate (IHW)
//IHWDay is NOT a subclass of NSDate! It is a CATEGORY of NSDate which adds new methods. ALL NSDate objects in this project have the IHWDate methods.

+ (IHWDate *)today {
    return [[IHWDate alloc] initToday];
}

- (id)initToday
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[self init]];
    self = [cal dateFromComponents:components];
    return self;
}

- (id)initWithMonth:(int)m day:(int)d year:(int)y
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = d;
    components.month = m;
    components.year = y;
    self = [cal dateFromComponents:components];
    return self;
}

- (id)initFromString:(NSString *)string
{
    NSArray *comps = [string componentsSeparatedByString:@"/"];
    self = [self initWithMonth:[[comps objectAtIndex:0] intValue] day:[[comps objectAtIndex:1] intValue] year:[[comps objectAtIndex:2] intValue]];
    return self;
}

-(int)month {
    return (int)[cal components:NSMonthCalendarUnit fromDate:self].month;
}

-(int)day {
    return (int)[cal components:NSDayCalendarUnit fromDate:self].day;
}

-(int)year {
    return (int)[cal components:NSYearCalendarUnit fromDate:self].year;
}

- (BOOL)isMonday {
    int weekday = (int)[cal components:NSWeekdayCalendarUnit fromDate:self].weekday;
    return weekday==2;
}

- (BOOL)isWeekend {
    int weekday = (int)[cal components:NSWeekdayCalendarUnit fromDate:self].weekday;
    return weekday==1 || weekday == 7;
}

- (NSDate *)dateByAddingDays:(int)days {
    return [[NSDate alloc] initWithTimeInterval:days*24*60*60 sinceDate:self];
}

- (NSDate *)dateOfNextSunday {
    int weekday = (int)[cal components:NSWeekdayCalendarUnit fromDate:self].weekday;
    int daysBehind = 8-weekday;
    return [self dateByAddingDays:daysBehind];
}

- (NSDate *)dateOfPreviousSunday {
    int weekday = (int)[cal components:NSWeekdayCalendarUnit fromDate:self].weekday;
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
    weekday.timeZone = cal.timeZone;
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

- (NSDate *)NSDateWithTime:(IHWTime *)time {
    //Adds a time to this date and returns the combined datetime.
    NSDateComponents *components = [cal components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:self];
    components.hour = time.hour;
    components.minute = time.minute;
    components.second = time.second;
    components.timeZone = [NSTimeZone localTimeZone];
    return [cal dateFromComponents:components];
}

+ (NSComparator)comparator {
    return ^(NSDate *obj1, NSDate *obj2) {
        return [obj1 compare:obj2];
    };
}

+ (void)initialize {
    cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    cal.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
}

- (NSString *) getCanvasDateString {
    NSString *month = nil;
    NSString *day = nil;
    if(self.month<10)
        month = [NSString stringWithFormat:@"0%d", self.month];
    else
        month = [NSString stringWithFormat:@"%d",  self.month];
    if(self.day<10)
        day = [NSString stringWithFormat:@"0%d", self.day];
    else
        day = [NSString stringWithFormat:@"%d",  self.day];
    return [NSString stringWithFormat:@"%d-%@-%@", self.year, month, day];
}


@end
