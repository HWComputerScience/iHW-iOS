//
//  IHWNormalDay.m
//  iHW
//
//  Created by Jonathan Burns on 7/10/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWNormalDay.h"
#import "IHWCurriculum.h"
#import "IHWTime.h"
#import "IHWPeriod.h"

@implementation IHWNormalDay

- (id)initWithBreak:(NSString *)breakName OnDate:(IHWDate *)date
             dayNum:(int)dayNum
 periodsBeforeBreak:(int)pbb
         afterBreak:(int)pab
        breakLength:(int)blength
       periodLength:(int)plength
{
    self = [super initWithDate:date];
    if (self) {
        self.dayNum = dayNum;
        self.periodsBeforeBreak = pbb;
        self.periodsAfterBreak = pab;
        self.numPeriods = self.periodsBeforeBreak + self.periodsAfterBreak;
        self.breakLength = blength;
        self.breakName = breakName;
        self.periodLength = plength;
        self.hasBreak = YES;
        self.periods = [NSMutableArray array];
    }
    return self;
}

- (id)initWithDate:(IHWDate *)date
            dayNum:(int)dayNum
        numPeriods:(int)numPeriods
      periodLength:(int)plength
{
    self = [super initWithDate:date];
    if (self) {
        self.dayNum = dayNum;
        self.numPeriods = numPeriods;
        self.periodsBeforeBreak = numPeriods;
        self.periodsAfterBreak = 0;
        self.periodLength = plength;
        self.hasBreak = NO;
        self.periods = [NSMutableArray array];
    }
    return self;
}

- (id)initWithJSONDictionary:(NSDictionary *)dictionary
{
    self = [super initWithJSONDictionary:dictionary];
    if (self) {
        self.dayNum = [[dictionary objectForKey:@"dayNumber"] intValue];
        self.hasBreak = [[dictionary objectForKey:@"hasBreak"] boolValue];
        self.periodLength = [[dictionary objectForKey:@"periodLength"] intValue];
        self.periodLengths = [dictionary objectForKey:@"periodLengths"];
        self.numPeriods = [[dictionary objectForKey:@"numPeriods"] intValue];
        if (self.hasBreak) {
            self.periodsBeforeBreak = [[dictionary objectForKey:@"periodsBeforeBreak"] intValue];
            self.periodsAfterBreak = [[dictionary objectForKey:@"periodsAfterBreak"] intValue];
            self.breakLength = [[dictionary objectForKey:@"breakLength"] intValue];
            self.breakName = [dictionary objectForKey:@"breakName"];
        } else {
            self.periodsBeforeBreak = self.numPeriods;
            self.periodsAfterBreak = 0;
        }
        self.periods = [NSMutableArray array];
    }
    return self;
}

- (void)fillPeriodsFromCurriculum:(IHWCurriculum *)c {
    NSArray *courseList = [c courseListForDate:self.date];
    self.periods = [NSMutableArray array];
    IHWTime *nextStart = c.dayStartTime;
    int index = 0;
    
    //add periods before break
    for (int num=1; num<=self.periodsBeforeBreak; num++) {
        IHWTime *endTime = [self addPeriodWithNum:num fromCourseList:courseList atIndex:index startTime:nextStart];
        nextStart = [endTime timeByAddingHours:0 andMinutes:c.passingPeriodLength];
        index++;
    }
    
    if (self.hasBreak) {
        //add break
        [self.periods addObject:[[IHWPeriod alloc] initWithName:self.breakName date:self.date start:nextStart end:[nextStart timeByAddingHours:0 andMinutes:self.breakLength] number:0 index:index]];
        index++;
        nextStart = [nextStart timeByAddingHours:0 andMinutes:(self.breakLength+c.passingPeriodLength)];
    }
    //add periods after break
    for (int num = self.periodsBeforeBreak+1; num<=self.periodsBeforeBreak+self.periodsAfterBreak; num++) {
        IHWTime *endTime = [self addPeriodWithNum:num fromCourseList:courseList atIndex:index startTime:nextStart];
        nextStart = [endTime timeByAddingHours:0 andMinutes:c.passingPeriodLength];
        index++;
    }
}

- (IHWTime *)addPeriodWithNum:(int)num fromCourseList:(NSArray *)courseList atIndex:(int)index startTime:(IHWTime *)startTime {
    int duration = self.periodLength;
    if (self.periodLengths != nil && [self.periodLengths objectForKey:[[NSNumber numberWithInt:num] stringValue]] != nil) {
        duration = [[self.periodLengths objectForKey:[[NSNumber numberWithInt:num] stringValue]] intValue];
    }
    if ([courseList objectAtIndex:num] != [NSNull null]) {
        IHWCourse *course = [courseList objectAtIndex:num];
        IHWPeriod *period = [[IHWPeriod alloc] initWithName:course.name date:self.date start:startTime end:[startTime timeByAddingHours:0 andMinutes:duration] number:num index:index];
        [self.periods addObject:period];
    } else {
        [self.periods addObject:[[IHWPeriod alloc] initWithName:@"X" date:self.date start:startTime end:[startTime timeByAddingHours:0 andMinutes:duration] number:num index:index]];
    }
    return [startTime timeByAddingHours:0 andMinutes:duration];
}

- (NSDictionary *)saveDay {
    NSMutableDictionary *dict = [[super saveDay] mutableCopy];
    [dict setValue:@"normal" forKey:@"type"];
    [dict setValue:[NSNumber numberWithInt:self.dayNum] forKey:@"dayNumber"];
    [dict setValue:[NSNumber numberWithBool:self.hasBreak] forKey:@"hasBreak"];
    [dict setValue:[NSNumber numberWithInt:self.periodLength] forKey:@"periodLength"];
    [dict setValue:[NSNumber numberWithInt:self.numPeriods] forKey:@"numPeriods"];
    if (self.hasBreak) {
        [dict setValue:[NSNumber numberWithInt:self.periodsBeforeBreak] forKey:@"periodsBeforeBreak"];
        [dict setValue:[NSNumber numberWithInt:self.periodsAfterBreak] forKey:@"periodsAfterBreak"];
        [dict setValue:[NSNumber numberWithInt:self.breakLength] forKey:@"breakLength"];
        [dict setValue:self.breakName forKey:@"breakName"];
    }
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSString *)title {
    if (self.dayNum > 0) return [NSString stringWithFormat:@"%@ (Day %d)", [super title], self.dayNum];
    else return [super title];
}

@end
