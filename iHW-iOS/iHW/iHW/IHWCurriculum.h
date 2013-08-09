//
//  IHWLogic.h
//  iHW
//
//  Created by Andrew Friedman on 7/10/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MutableOrderedDictionary.h"
#import "IHWDate.h"
#import "IHWDay.h"

typedef enum {
    CAMPUS_MIDDLE = 6,
    CAMPUS_UPPER = 5
} CAMPUS;

typedef enum {
    TERM_FULL_YEAR = 0,
    TERM_FIRST_SEMESTER,
    TERM_SECOND_SEMESTER,
    TERM_FIRST_TRIMESTER,
    TERM_SECOND_TRIMESTER,
    TERM_THIRD_TRIMESTER
} COURSE_TERM;

@interface IHWCurriculum : NSObject

+ (IHWCurriculum *)currentCurriculum;



@property int campus;
@property int year;
@property int passingPeriodLength;
@property int loadingProgress;
@property NSMutableSet *courses;
@property NSDictionary *normalDayTemplate;
@property NSDictionary *normalMondayTemplate;
@property MutableOrderedDictionary *specialDayTemplates;
@property MutableOrderedDictionary *loadedWeeks;
@property MutableOrderedDictionary *loadedDays;
@property MutableOrderedDictionary *dayNumbers;
@property NSArray *semesterEndDates;
@property NSArray *trimesterEndDates;
@property NSMutableSet *modelLoadingListeners;

- (id)initWithCampus:(int)campus year:(int)year startingDate:(IHWDate *)date;
- (void)loadEverything;
- (IHWDate *)firstLoadedDate;
- (IHWDate *)lastLoadedDate;
- (BOOL)dayIsLoaded:(IHWDate *)date;
- (IHWDay *)getDayWithDate:(IHWDate *)date;
- (void)clearUnneededItems:(IHWDate *)date;

@end
