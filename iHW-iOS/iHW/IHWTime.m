//
//  IHWTime.m
//  iHW
//
//  Created by Andrew Friedman on 6/14/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import "IHWTime.h"

@implementation IHWTime

- (id)initWithHours:(int)hours andMinutes:(int)minutes {
    self = [super init];
    if (self) {
        self.hour = hours;
        self.minute = minutes;
    }
    return self;
}

- (int)getHourTwelve {
    int toReturn = self.hour%12;
    if (toReturn == 0) return 12;
    else return toReturn;
}


@end
