//
//  IHWTime.h
//  iHW
//
//  Created by Jonathan Burns on 8/8/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IHWTime : NSObject

@property int hour;
@property int minute;
@property int second;

- (id)initNow;
- (id)initWithHour:(int)hour andMinute:(int)minute;
- (id)initWithHour:(int)hour minute:(int)minute andPM:(BOOL)isPM;
- (id)initFromString:(NSString *)string;
- (int)hour12;
- (BOOL)isPM;
- (IHWTime *)timeByAddingHours:(int)hours andMinutes:(int)minutes;
- (int)minutesUntilTime:(IHWTime *)other;
- (int)secondsUntilTime:(IHWTime *)other;
- (NSString *)description;
- (NSString *)description12;

+ (NSComparator)comparator;

@end
