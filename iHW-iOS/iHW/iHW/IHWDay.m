//
//  IHWDay.m
//  iHW
//
//  Created by Andrew Friedman on 7/10/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import "IHWDay.h"

@implementation IHWDay

- (id)initWithDate:(IHWDate *)date
{
    self = [super init];
    if (self) {
        self.date = date;
    }
    return self;
}

- (id)initWithJSONDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.date = [[IHWDate alloc] initFromString:[dictionary objectForKey:@"date"]];
    }
    return self;
}

- (NSDictionary *)saveDay {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.date.description forKey:@"date"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSString *)title {
    return self.date.description;
}

@end
