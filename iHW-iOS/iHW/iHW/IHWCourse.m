//
//  IHWCourse.m
//  iHW
//
//  Created by Andrew Friedman on 7/10/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import "IHWCourse.h"

@implementation IHWCourse

- (id)initWithName:(NSString *)n period:(int)p term:(int)t meetings:(NSArray *)m
{
    self = [super init];
    if (self) {
        self.name = n;
        self.period = p;
        self.term = t;
        self.meetings = m;
    }
    return self;
}

- (int)getNumMeetings {
    int sum = 0;
    for (int index = 0; index <self.meetings.count; index++) {
        if ([[self.meetings objectAtIndex:index] intValue] == MEETING_NORMAL) {
            sum++;
        } else if ([[self.meetings objectAtIndex:index] intValue] == MEETING_DOUBLE_AFTER || [[self.meetings objectAtIndex:index] intValue] == MEETING_DOUBLE_BEFORE) {
            sum+=2;
        }
    }
    return sum;
}

@end
