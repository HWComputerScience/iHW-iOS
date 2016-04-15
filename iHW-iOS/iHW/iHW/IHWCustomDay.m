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
        //NSLog(@"Tests: %@", tests);
        self.periods = [tests mutableCopy];
    }
    return self;
}

- (id)initWithJSONDictionary:(NSDictionary *)dictionary
{
    self = [super initWithJSONDictionary:dictionary];
    if (self) {
        NSArray *dicts = [dictionary objectForKey:@"tests"];
        //NSLog(@"Test dictionary: %@", dicts);
        self.periods = [NSMutableArray array];
        int i=0;
        for (NSDictionary *periodDict in dicts) {
            //Create each period and add it
            [self.periods addObject:[[IHWPeriod alloc] initWithJSONDictionary:periodDict atIndex:i]];
            i++;
        }
        //NSLog(@"Periods: %@", self.periods);
    }
    return self;
}

- (NSDictionary *)saveDay {
    NSMutableDictionary *dict = [[super saveDay] mutableCopy];
    [dict setValue:@"test" forKey:@"type"];
    NSMutableArray *dicts = [NSMutableArray array];
    for (IHWPeriod *p in self.periods) {
        //Save each period and add it
        [dicts addObject:[p savePeriod]];
    }
    [dict setValue:dicts forKey:@"tests"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
