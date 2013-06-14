//
//  IHWSchedule.h
//  iHW
//
//  Created by Andrew Friedman on 6/14/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TERM_FULL_YEAR 0;
#define TERM_FIRST_SEMESTER 1;
#define TERM_SECOND_SEMESTER 2;
#define TERM_FIRST_TRIMESTER 3;
#define TERM_SECOND_TRIMESTER 4;
#define TERM_THIRD_TRIMESTER 5;

#define CAMPUS_MIDDLE 6;
#define CAMPUS_UPPER 5;

@interface IHWSchedule : NSObject

@property int campus;
@property NSSet *courses;
@property int passingPeriodLength;
@property NSDictionary *specialDays;
@property NSDictionary *dayNumbers;
//          (cycle)             (period->array<note>)
//NSArray<NSDictionary<NSDate, NSArray<NSArray<Note>>>>()
@property NSArray *cycleNotes;
@property int year;
@property NSArray *semesterEndDates;
@property NSArray *trimesterEndDates;



@end
