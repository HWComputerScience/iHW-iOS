//
//  IHWDay.m
//  iHW
//
//  Created by Jonathan Burns on 7/10/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
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
        self.caption = [dictionary objectForKey:@"caption"];
        self.captionLink = [dictionary objectForKey:@"captionLink"];
    }
    return self;
}

- (NSDictionary *)saveDay {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.date.description forKey:@"date"];
    [dict setObject:self.caption forKey:@"caption"];
    [dict setObject:self.captionLink forKey:@"captionLink"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSString *)title {
    return self.date.description;
}

@end
