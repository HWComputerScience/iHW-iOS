//
//  IHWCustomDay.m
//  iHW
//
//  Created by Jonathan Burns on 7/10/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWCustomDay.h"
#import "IHWPeriod.h"

@implementation IHWCustomDay

- (id)initWithTests:(NSArray *)tests onDate:(IHWDate *)date
{
    self = [super initWithDate:date];
    if (self) {
        self.periods = [tests mutableCopy];
    }
    return self;
}

- (id)initWithJSONDictionary:(NSDictionary *)dictionary
{
    self = [super initWithJSONDictionary:dictionary];
    if (self) {
        NSArray *dicts = [dictionary objectForKey:@"tests"];
        self.periods = [NSMutableArray array];
        for (NSDictionary *periodDict in dicts) {
            [self.periods addObject:[[IHWPeriod alloc] initWithJSONDictionary:periodDict]];
        }
    }
    return self;
}

- (NSDictionary *)saveDay {
    NSMutableDictionary *dict = [[super saveDay] mutableCopy];
    [dict setValue:@"test" forKey:@"type"];
    NSMutableArray *dicts = [NSMutableArray array];
    for (IHWPeriod *p in self.periods) {
        [dicts addObject:[p savePeriod]];
    }
    [dict setValue:dicts forKey:@"tests"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
