//
//  IHWDate.h
//  iHW
//
//  Created by Jonathan Burns on 7/11/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NSDate IHWDate;

@interface NSDate (IHW)

+ (IHWDate *)IHWDate;

- (id)initIHWDate;
- (id)initWithMonth:(int)m day:(int)d year:(int)y;
- (id)initFromString:(NSString *)string;

-(int)month;
-(int)day;
-(int)year;

- (BOOL)isMonday;
- (BOOL)isWeekend;
- (NSDate *)dateByAddingDays:(int)days;
- (NSDate *)dateOfNextSunday;
- (NSDate *)dateOfPreviousSunday;
- (NSString *)description;
- (int)daysUntilDate:(NSDate *)other;
- (NSString *)dayOfWeek:(BOOL)shortVersion;
- (BOOL)isEqualToDate:(NSDate *)otherDate;

+ (NSComparator)comparator;

@end