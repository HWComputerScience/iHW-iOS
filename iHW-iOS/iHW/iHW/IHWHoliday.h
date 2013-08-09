//
//  IHWHoliday.h
//  iHW
//
//  Created by Andrew Friedman on 7/10/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import "IHWDay.h"

@interface IHWHoliday : IHWDay

@property (nonatomic, strong) NSString *name;

- (id)initWithName:(NSString *)name onDate:(IHWDate *)date;
- (id)initWithJSONDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)saveDay;

@end
