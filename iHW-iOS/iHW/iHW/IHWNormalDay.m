//
//  IHWNormalDay.m
//  iHW
//
//  Created by Andrew Friedman on 7/10/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import "IHWNormalDay.h"
#import "IHWCurriculum.h"

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
        self.numPeriods = [[dictionary objectForKey:@"numPeriods"] intValue];
        if (self.hasBreak) {
            self.periodsBeforeBreak = [[dictionary objectForKey:@"periodsBeforeBreak"] intValue];
            self.periodsAfterBreak = [[dictionary objectForKey:@"periodsAfterBreak"] intValue];
            self.breakLength = [[dictionary objectForKey:@"breakLength"] intValue];
            self.breakName = [dictionary objectForKey:@"breakName"];
        }
        self.periods = [NSMutableArray array];
    }
    return self;
}

- (void)fillPeriodsFromCurriculum:(IHWCurriculum *)c {
    #pragma mark TODO: fill periods
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
