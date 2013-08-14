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

- (id)init;
- (id)initWithMonth:(int)m day:(int)d year:(int)y;
- (id)initFromString:(NSString *)string;

-(int)month;
-(int)day;
-(int)year;

- (BOOL)isMonday;
- (BOOL)isWeekend;
- (IHWDate *)dateByAddingDays:(int)days;
- (IHWDate *)dateOfNextSunday;
- (IHWDate *)dateOfPreviousSunday;
- (NSString *)description;
- (int)daysUntilDate:(IHWDate *)other;
- (NSString *)dayOfWeek:(BOOL)shortVersion;
- (BOOL)isEqualToDate:(IHWDate *)otherDate;

+ (NSComparator)comparator;

@end
