//
//  IHWCourse.m
//  iHW
//
//  Created by Andrew Friedman on 6/14/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import "IHWCourse.h"

@implementation IHWCourse

- (id)initWithName:(NSString *)n
              term:(int)t
            period:(int)p
          meetings:(NSArray *)m
{
    self = [super init];
    if (self) {
        self.meetings = m;
        self.period = p;
        self.term = t;
        self.name = n;
    }
    return self;
}

- (int)getMeetingOnDay:(int)day {
    return [[self.meetings objectAtIndex:(day-1)] intValue];
}

@end
