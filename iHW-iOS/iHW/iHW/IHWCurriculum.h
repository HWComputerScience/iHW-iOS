//
//  IHWLogic.h
//  iHW
//
//  Created by Jonathan Burns on 7/10/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "MutableOrderedDictionary.h"
#import "IHWDate.h"
#import "IHWTime.h"
#import "IHWDay.h"
#import "IHWCourse.h"
#import "IHWConstants.h"

@interface IHWCurriculum : NSObject

+ (IHWCurriculum *)currentCurriculum;
+ (IHWCurriculum *)curriculumWithCampus:(int)campus andYear:(int)year;
+ (int)currentYear;
+ (int)currentCampus;
+ (void)setCurrentYear:(int)year;
+ (void)setCurrentCampus:(int)campus;
+ (BOOL)isFirstRun;



@property int campus;
@property int year;
@property int passingPeriodLength;
@property int loadingProgress;
@property (strong, nonatomic) NSMutableArray *courses;
@property (strong, nonatomic) IHWTime *dayStartTime;
@property (strong, nonatomic) NSDictionary *normalDayTemplate;
@property (strong, nonatomic) NSDictionary *normalMondayTemplate;
@property (strong, nonatomic) NSDictionary *specialDayTemplates;
@property (strong) NSMutableDictionary *loadedWeeks;
@property (strong) NSMutableDictionary *loadedDays;
@property (strong, nonatomic) NSMutableDictionary *dayNumbers;
@property (strong, nonatomic) NSArray *semesterEndDates;
@property (strong, nonatomic) NSArray *trimesterEndDates;
@property (strong) NSMutableSet *curriculumLoadingListeners;
@property (strong, nonatomic) NSOperationQueue *loadingQueue;

- (id)initWithCampus:(int)campus year:(int)year startingDate:(IHWDate *)date;
- (void)loadEverythingWithStartingDate:(IHWDate *)date;
- (BOOL)isLoading;
- (BOOL)isLoaded;
//- (IHWDate *)firstLoadedDate;
//- (IHWDate *)lastLoadedDate;
- (BOOL)dayIsLoaded:(IHWDate *)date;
- (IHWDay *)dayWithDate:(IHWDate *)date;
- (void)clearUnneededItems:(IHWDate *)date;
- (BOOL)dateInBounds:(IHWDate *)date;

- (NSArray *)allCourseNames;
- (BOOL)addCourse:(IHWCourse *)c;
- (void)removeCourse:(IHWCourse *)c;
- (void)removeAllCourses;
//- (BOOL)replaceCourseWithName:(NSString *)oldName withCourse:(IHWCourse *)c;
//- (IHWCourse *)courseWithName:(NSString *)name;
- (BOOL)replaceCourseAtIndex:(NSInteger)index withCourse:(IHWCourse *)c;
- (IHWCourse *)courseAtIndex:(NSInteger)index;
- (IHWCourse *)courseMeetingOnDate:(IHWDate *)d period:(int)period;
- (NSArray *)courseListForDate:(IHWDate *)d;
- (NSArray *)termsFromDate:(IHWDate *)d;

- (NSArray *)notesOnDate:(IHWDate *)date period:(int)period;
- (void)setNotes:(NSArray *)notes onDate:(IHWDate *)date period:(int)period;

- (void)saveWeekWithDate:(IHWDate *)d;
- (void)saveCourses;

@end

@protocol IHWCurriculumLoadingListener <NSObject>
@optional
- (void)curriculumFinishedLoading:(IHWCurriculum *)curriculum;
- (void)curriculumFailedToLoad:(IHWCurriculum *)curriculum;
@end
