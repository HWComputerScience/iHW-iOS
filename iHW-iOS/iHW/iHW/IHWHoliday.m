//
//  IHWHoliday.m
//  iHW
//
//  Created by Jonathan Burns on 7/10/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWHoliday.h"

@implementation IHWHoliday

- (id)initWithName:(NSString *)name onDate:(IHWDate *)date
{
    self = [super initWithDate:date];
    if (self) {
        self.name = name;
        self.periods = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (id)initWithJSONDictionary:(NSDictionary *)dictionary
{
    self = [super initWithJSONDictionary:dictionary];
    if (self) {
        self.name = [dictionary objectForKey:@"name"];
        self.periods = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (NSDictionary *)saveDay {
    NSMutableDictionary *dict = [[super saveDay] mutableCopy];
    [dict setValue:@"holiday" forKey:@"type"];
    [dict setValue:self.name forKey:@"name"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
