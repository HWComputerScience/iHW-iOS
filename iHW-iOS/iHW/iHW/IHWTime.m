//
//  IHWTime.m
//  iHW
//
//  Created by Jonathan Burns on 8/8/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWTime.h"

@implementation IHWTime

+ (IHWTime *)now {
    return [[self alloc] initNow];
}

- (id)initNow
{
    self = [super init];
    if (self) {
        NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[NSDate date]];
        self.hour = (int)comps.hour;
        self.minute = (int)comps.minute;
        self.second = (int)comps.second;
    }
    return self;
}

- (id)initWithHour:(int)hour andMinute:(int)minute
{
    self = [super init];
    if (self) {
        if (hour<0 || hour>23 || minute<0 || minute>59) {
            [NSException raise:@"IllegalArgumentException" format:@"The hour or minute supplied to IHWTime was invalid."];
        }
        self.hour = hour;
        self.minute = minute;
        self.second = 0;
    }
    return self;
}

- (id)initWithHour:(int)hour minute:(int)minute andPM:(BOOL)isPM
{
    self = [super init];
    if (self) {
        if (hour<1 || hour>12 || minute<0 || minute>59) {
            [NSException raise:@"IllegalArgumentException" format:@"The hour or minute supplied to IHWTime was invalid."];
        }
        if (isPM && hour != 12) self.hour = hour+12;
        else if (!isPM && hour == 12) self.hour = hour-12;
        else self.hour = hour;
        self.minute = minute;
        self.second = 0;
    }
    return self;
}

- (id)initFromString:(NSString *)string
{
    self = [super init];
    if (self) {
        NSArray *comps = [string componentsSeparatedByString:@":"];
        self.hour = [[comps objectAtIndex:0] intValue];
        self.minute = [[comps objectAtIndex:1] intValue];
        self.second = 0;
    }
    return self;
}

- (int)hour12 {
    int ret = self.hour%12;
    if (ret==0) ret = 12;
    return ret;
}

- (BOOL)isPM {
    return self.hour >= 12;
}

- (IHWTime *)timeByAddingHours:(int)hours andMinutes:(int)minutes {
    int newHours = self.hour+hours;
    int newMinutes = self.minute+minutes;
    if (minutes>=0 && hours>=0) {
        while (newMinutes >= 60) {
            newHours++;
            newMinutes-=60;
        }
        newHours = newHours%24;
        IHWTime *newTime = [[IHWTime alloc] initWithHour:newHours andMinute:newMinutes];
        newTime.second = self.second;
        return newTime;
    } else if (minutes<=0 && hours<=0) {
        while (newMinutes < 0) {
            newHours--;
            newMinutes+=60;
        }
        while (newHours<0) {
            newHours+=24;
        }
        newHours = newHours%24;
        IHWTime *newTime = [[IHWTime alloc] initWithHour:newHours andMinute:newMinutes];
        newTime.second = self.second;
        return newTime;
    }
    [NSException raise:@"IllegalArgumentException" format:@"Could not add the specified hours and minutes to this time."];
    return nil;
}

- (int)minutesUntilTime:(IHWTime *)other {
    return 60*(other.hour-self.hour) + other.minute-self.minute;
}

- (int)secondsUntilTime:(IHWTime *)other {
    return 60*[self minutesUntilTime:other] + other.second-self.second;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%d:%02d", self.hour, self.minute];
}

- (NSString *)description12 {
    NSString *ampm;
    if ([self isPM]) ampm = @"PM";
    else ampm = @"AM";
    return [NSString stringWithFormat:@"%d:%02d %@", [self hour12], self.minute, ampm];
}

+ (NSComparator)comparator {
    return ^(IHWTime *obj1, IHWTime *obj2) {
        int result = obj1.hour - obj2.hour;
        if (result == 0) result = obj1.minute - obj2.minute;
        if (result == 0) result = obj1.second - obj2.second;
        if (result == 0) return NSOrderedSame;
        else if (result < 0) return NSOrderedAscending;
        return NSOrderedDescending;
    };
}

@end
