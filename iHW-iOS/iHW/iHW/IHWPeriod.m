//
//  IHWPeriod.m
//  iHW
//
//  Created by Jonathan Burns on 7/10/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWPeriod.h"
#import "IHWDate.h"


@implementation IHWPeriod

- (id)initWithName:(NSString *)name date:(IHWDate *)date start:(IHWTime *)start end:(IHWTime *)end number:(int)periodNum
{
    self = [super init];
    if (self) {
        self.name = name;
        self.date = date;
        self.startTime = start;
        self.endTime = end;
        self.periodNum = periodNum;
    }
    return self;
}

- (id)initWithJSONDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.name = [dictionary objectForKey:@"name"];
        self.date = [[IHWDate alloc] initFromString:[dictionary objectForKey:@"date"]];
        self.startTime = [[IHWTime alloc] initFromString:[dictionary objectForKey:@"startTime"]];
        self.endTime = [[IHWTime alloc] initFromString:[dictionary objectForKey:@"endTime"]];
        self.periodNum = [[dictionary objectForKey:@"periodNum"] intValue];
    }
    return self;
}

- (NSDictionary *)savePeriod {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.name forKey:@"name"];
    [dict setObject:self.date.description forKey:@"date"];
    [dict setObject:self.startTime.description forKey:@"startTime"];
    [dict setObject:self.endTime.description forKey:@"endTime"];
    [dict setObject:[NSNumber numberWithInt:self.periodNum] forKey:@"periodNum"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
